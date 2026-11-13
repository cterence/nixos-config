package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLatestBuildMemoizes(t *testing.T) {
	hits := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if ua := r.Header.Get("User-Agent"); ua == "" {
			t.Error("LatestBuild sent no User-Agent")
		}
		hits++
		if r.URL.Path == "/job/nixpkgs/unstable/missing.x86_64-linux/latest" {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		w.Write([]byte(`{"id":1,"finished":1,"buildstatus":0,"nixname":"foo-1","job":"foo.x86_64-linux","drvpath":"/nix/store/xxx-foo-1.drv"}`))
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL

	for range 3 {
		if _, err := h.LatestBuild("foo.x86_64-linux"); err != nil {
			t.Fatalf("LatestBuild: %v", err)
		}
	}
	if hits != 1 {
		t.Fatalf("LatestBuild hit the server %d times, want 1 (memoized)", hits)
	}

	for range 3 {
		b, err := h.LatestBuild("missing.x86_64-linux")
		if err != nil || b != nil {
			t.Fatalf("LatestBuild missing = (%v, %v), want (nil, nil)", b, err)
		}
	}
	if hits != 2 {
		t.Fatalf("LatestBuild hit the server %d times total, want 2 (404 memoized)", hits)
	}
}
