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

func TestClosureFlagSet(t *testing.T) {
	tests := []struct {
		in                 string
		host, attr, system string
		wantErr            bool
	}{
		{"stronghold=nixosConfigurations.stronghold.config.system.build.toplevel", "stronghold", "nixosConfigurations.stronghold.config.system.build.toplevel", "", false},
		{"arm=nixosConfigurations.arm.config.system.build.toplevel:aarch64-linux", "arm", "nixosConfigurations.arm.config.system.build.toplevel", "aarch64-linux", false},
		{"macbook=darwinConfigurations.macbook.system", "macbook", "darwinConfigurations.macbook.system", "", false},
		{"noequalsign", "", "", "", true},
	}
	for _, tt := range tests {
		t.Run(tt.in, func(t *testing.T) {
			var c closureFlags
			err := c.Set(tt.in)
			if (err != nil) != tt.wantErr {
				t.Fatalf("Set(%q) err = %v, wantErr %v", tt.in, err, tt.wantErr)
			}
			if err != nil {
				return
			}
			got := c[0]
			if got.host != tt.host || got.attr != tt.attr || got.system != tt.system {
				t.Fatalf("Set(%q) = %+v, want {host:%q attr:%q system:%q}", tt.in, got, tt.host, tt.attr, tt.system)
			}
		})
	}
}

func TestClosureSystem(t *testing.T) {
	if got := closureSystem("darwinConfigurations.macbook.system", ""); got != darwinPlatform {
		t.Errorf("darwin attr auto-detect = %q, want %q", got, darwinPlatform)
	}
	if got := closureSystem("nixosConfigurations.stronghold.config.system.build.toplevel", ""); got != linuxPlatform {
		t.Errorf("nixos attr auto-detect = %q, want %q", got, linuxPlatform)
	}
	if got := closureSystem("nixosConfigurations.arm.config.system.build.toplevel", "aarch64-linux"); got != "aarch64-linux" {
		t.Errorf("explicit system ignored: %q", got)
	}
}
