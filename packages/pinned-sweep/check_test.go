package main

import "testing"

func TestClosureJobs(t *testing.T) {
	pinned := map[string]Pin{"calibre": {Version: "9.14.0"}}
	drvPaths := []string{
		"/nix/store/aaa-picard-3.0.2.drv",
		"/nix/store/bbb-unit-firewall.service.drv",
		"/nix/store/ccc-hm_..zshrc.drv",
		"/nix/store/ddd-qbittorrent-5.2.4.drv",
		"/nix/store/eee-qbittorrent-5.3.0.drv", // dup pkg, deduped
		"/nix/store/fff-calibre-9.14.0.drv",    // pinned
		"/nix/store/ggg-bashrc.drv",
	}
	got := closureJobs(drvPaths, pinned)
	if len(got) != 2 {
		t.Fatalf("closureJobs returned %d jobs (%v), want 2", len(got), got)
	}
	if got[0].pkg != "picard" || got[0].version != "3.0.2" {
		t.Errorf("closureJobs[0] = %q@%q, want picard@3.0.2", got[0].pkg, got[0].version)
	}
	if got[1].pkg != "qbittorrent" || got[1].version != "5.2.4" {
		t.Errorf("closureJobs[1] = %q@%q, want qbittorrent@5.2.4", got[1].pkg, got[1].version)
	}
}
