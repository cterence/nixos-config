package main

import (
	"slices"
	"testing"
)

func TestAttrCandidates(t *testing.T) {
	tests := []struct {
		pkg  string
		want []string
	}{
		// The bug this guards: the drv name is glibc-locales, Hydra's job is
		// glibcLocales.x86_64-linux.
		{"glibc-locales", []string{"glibc-locales", "glibcLocales"}},
		{"hello", []string{"hello"}},
		{"python3.13-foo", []string{"python3.13-foo", "python3.13Foo"}},
		{"gnome-shell-extensions", []string{"gnome-shell-extensions", "gnomeShellExtensions"}},
	}
	for _, tt := range tests {
		t.Run(tt.pkg, func(t *testing.T) {
			if got := attrCandidates(tt.pkg); !slices.Equal(got, tt.want) {
				t.Fatalf("attrCandidates(%q) = %v, want %v", tt.pkg, got, tt.want)
			}
		})
	}
}

func TestAttrMatches(t *testing.T) {
	tests := []struct {
		name string
		info attrInfo
		job  job
		want bool
	}{
		{"same pname, drv version has a suffix", attrInfo{"glibc-locales", "2.44"}, job{pkg: "glibc-locales", version: "2.44-57"}, true},
		{"different pname", attrInfo{"glibc", "2.44"}, job{pkg: "glibc-locales", version: "2.44-57"}, false},
		{"drv version older than the attr", attrInfo{"picard", "3.0.2"}, job{pkg: "picard", version: "2.9"}, false},
		{"attr carries no metadata", attrInfo{}, job{pkg: "picard", version: "3.0.2"}, true},
		{"attr has no version", attrInfo{Pname: "picard"}, job{pkg: "picard", version: "3.0.2"}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := attrMatches(tt.info, tt.job); got != tt.want {
				t.Fatalf("attrMatches(%+v, %+v) = %v, want %v", tt.info, tt.job, got, tt.want)
			}
		})
	}
}

func TestIsGranularCargoDrv(t *testing.T) {
	for _, pkg := range []string{"cargo-src-itoa", "cargo-package-tokio"} {
		if !isGranularCargoDrv(pkg) {
			t.Errorf("isGranularCargoDrv(%q) = false, want true", pkg)
		}
	}
	for _, pkg := range []string{"cargo", "cargo-nextest", "cargoSort", "picard"} {
		if isGranularCargoDrv(pkg) {
			t.Errorf("isGranularCargoDrv(%q) = true, want false", pkg)
		}
	}
}
