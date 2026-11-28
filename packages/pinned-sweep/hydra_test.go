package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"
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

func TestLatestBuildRetriesOn429(t *testing.T) {
	hits := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hits++
		if hits == 1 {
			w.Header().Set("Retry-After", "0")
			w.WriteHeader(http.StatusTooManyRequests)
			return
		}
		w.Write([]byte(`{"id":1,"finished":1,"buildstatus":0,"nixname":"foo-1","job":"foo.x86_64-linux","drvpath":"/nix/store/xxx-foo-1.drv"}`))
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL

	b, err := h.LatestBuild("foo.x86_64-linux")
	if err != nil {
		t.Fatalf("LatestBuild after 429: %v", err)
	}
	if b == nil {
		t.Fatal("LatestBuild after 429 returned nil, want the build")
	}
	if hits != 2 {
		t.Fatalf("LatestBuild hit the server %d times, want 2 (one 429, one ok)", hits)
	}
}

func TestLatestBuildFailsAfterPersistent429(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Retry-After", "0")
		w.WriteHeader(http.StatusTooManyRequests)
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL

	if _, err := h.LatestBuild("foo.x86_64-linux"); err == nil {
		t.Fatal("LatestBuild succeeded against a persistent 429, want an error")
	}
}

// Without a Retry-After header the fallback backoff must stay local to the
// throttled request: a shared freeze is what turned a slow gate into a
// 22-minute timeout.
func Test429WithoutRetryAfterDoesNotFreezeEveryWorker(t *testing.T) {
	hits := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hits++
		if hits == 1 {
			w.WriteHeader(http.StatusTooManyRequests)
			return
		}
		w.Write([]byte(`{"id":1,"finished":1,"buildstatus":0,"nixname":"foo-1","job":"foo.x86_64-linux","drvpath":"/nix/store/xxx-foo-1.drv"}`))
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL

	if _, err := h.LatestBuild("foo.x86_64-linux"); err != nil {
		t.Fatalf("LatestBuild after a bare 429: %v", err)
	}
	h.cdMu.Lock()
	frozen := !h.cdUntil.IsZero()
	h.cdMu.Unlock()
	if frozen {
		t.Fatal("a 429 without Retry-After set the shared cooldown, want a per-request backoff")
	}
}

// Total in-flight requests are capped process-wide, not per closure: Hydra
// 429s above a handful of concurrent queries.
func TestConcurrencyCap(t *testing.T) {
	var mu sync.Mutex
	inFlight, peak := 0, 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		inFlight++
		peak = max(peak, inFlight)
		mu.Unlock()
		time.Sleep(20 * time.Millisecond)
		mu.Lock()
		inFlight--
		mu.Unlock()
		w.Write([]byte(`{"id":1,"finished":1,"buildstatus":0,"nixname":"foo-1","job":"foo.x86_64-linux","drvpath":"/nix/store/xxx-foo-1.drv"}`))
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL

	var wg sync.WaitGroup
	for i := range 3 * hydraConcurrency {
		wg.Go(func() {
			if _, err := h.LatestBuild(fmt.Sprintf("foo%d.x86_64-linux", i)); err != nil {
				t.Errorf("LatestBuild: %v", err)
			}
		})
	}
	wg.Wait()
	if peak > hydraConcurrency {
		t.Fatalf("%d requests in flight, want at most %d", peak, hydraConcurrency)
	}
}

func TestGetStopsOnContextDeadline(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{}`))
	}))
	defer srv.Close()
	h := NewHydra()
	h.Base = srv.URL
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	h.ctx = ctx

	if _, err := h.LatestBuild("foo.x86_64-linux"); !errors.Is(err, context.Canceled) {
		t.Fatalf("LatestBuild with a cancelled context = %v, want context.Canceled", err)
	}
}
