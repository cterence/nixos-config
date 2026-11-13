package main

import (
	"encoding/json"
	"os"
	"strings"
	"testing"
)

func TestRetargetPin(t *testing.T) {
	existing := Pin{Version: "0.15.1"}
	green := &Build{NixName: "protonup-rs-0.15.1", Timestamp: 1792698000} // 2026-10-22
	tests := []struct {
		name     string
		pin      Pin
		lastGood string
		build    *Build
		changed  bool
		revision string
	}{
		{"drift: same version frozen to green revision", existing, "0.15.1", green, true, "2026-10-22"},
		{"version bump: no freeze, manual", existing, "0.15.0", green, false, ""},
		{"no last good: no freeze", existing, "", green, false, ""},
		{"no build: no freeze", existing, "0.15.1", nil, false, ""},
		{"already frozen: idempotent", Pin{Version: "0.15.1", Revision: "2026-10-22"}, "0.15.1", green, false, "2026-10-22"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, changed := retargetPin(tt.pin, tt.lastGood, tt.build)
			if changed != tt.changed {
				t.Fatalf("retargetPin changed = %v, want %v", changed, tt.changed)
			}
			if got.Revision != tt.revision {
				t.Fatalf("retargetPin revision = %q, want %q", got.Revision, tt.revision)
			}
		})
	}
}

func TestEmitPinsRevision(t *testing.T) {
	p := PinSets{
		Nixos: map[string]Pin{
			"protonup-rs": {Version: "0.15.1", Revision: "2026-10-22", Reason: "deps relocked"},
		},
	}
	out := emitPins(p)
	if !strings.Contains(out, "\n_:\n") {
		t.Error("emitPins must keep the `_:` module head; `{ ... }:` trips static checks")
	}
	if strings.Contains(out, "{ ... }:") {
		t.Error("emitPins must not emit a `{ ... }:` module head")
	}
	for _, want := range []string{
		`version = "0.15.1";`,
		`revision = "2026-10-22";`,
	} {
		if !strings.Contains(out, want) {
			t.Errorf("emitPins missing %q in:\n%s", want, out)
		}
	}
	p2 := PinSets{Nixos: map[string]Pin{"calibre": {Version: "9.14.0"}}}
	if strings.Contains(emitPins(p2), "revision = ") {
		t.Error("pins without revision must not render a revision field")
	}
}

func TestSplitPkgName(t *testing.T) {
	tests := []struct {
		in, pkg, ver string
	}{
		{"picard-3.0.2", "picard", "3.0.2"},
		{"qbittorrent-5.2.4", "qbittorrent", "5.2.4"},
		{"glibc-2.40-36", "glibc", "2.40-36"},
		{"python3.13-foo-1.2", "python3.13-foo", "1.2"},
		{"bash", "bash", ""},
	}
	for _, tt := range tests {
		t.Run(tt.in, func(t *testing.T) {
			pkg, ver := splitPkgName(tt.in)
			if pkg != tt.pkg || ver != tt.ver {
				t.Fatalf("splitPkgName(%q) = (%q, %q), want (%q, %q)", tt.in, pkg, ver, tt.pkg, tt.ver)
			}
		})
	}
}

func TestParseDryRun(t *testing.T) {
	out := `this derivation will be built:
  /nix/store/abc123-picard-3.0.2.drv
these 2 derivations will be built:
  /nix/store/def456-qbittorrent-5.2.4.drv
  /nix/store/ghi789-somethingelse-1.0.drv
these 3 paths will be fetched:
  /nix/store/xyz-out-picard-3.0.2
  /nix/store/abc123-picard-3.0.2.drv
warning: something unrelated`
	got := parseDryRun(out)
	want := []string{
		"/nix/store/abc123-picard-3.0.2.drv",
		"/nix/store/def456-qbittorrent-5.2.4.drv",
		"/nix/store/ghi789-somethingelse-1.0.drv",
	}
	if len(got) != len(want) {
		t.Fatalf("parseDryRun = %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("parseDryRun[%d] = %q, want %q", i, got[i], want[i])
		}
	}
}

func TestEmitPinsRoundTrip(t *testing.T) {
	p := PinSets{
		Darwin: map[string]Pin{
			"picard": {Version: "2.13.3", Tracker: "https://github.com/NixOS/nixpkgs/issues/572435", Reason: `says "hi" ${now}`},
		},
		Nixos: map[string]Pin{},
	}
	out := emitPins(p)
	for _, want := range []string{
		`_:`,
		`flake.pins = pins;`,
		`darwin = {`,
		`version = "2.13.3";`,
		`tracker = "https://github.com/NixOS/nixpkgs/issues/572435";`,
		`reason = "says \"hi\" \${now}";`,
		`nixos = { };`,
		`modules/system/types/base/system-minimal.nix`,
	} {
		if !strings.Contains(out, want) {
			t.Errorf("emitPins missing %q in:\n%s", want, out)
		}
	}
	if strings.Contains(out, "overlays") {
		t.Error("pins.nix is data only; the overlay lives in system-minimal.nix")
	}
	if strings.Index(out, "darwin = {") > strings.Index(out, "nixos = {") {
		t.Error("emitPins must emit darwin before nixos")
	}
}

func TestVerdictFor(t *testing.T) {
	current := "/nix/store/aaa-qbittorrent-5.2.4.drv"
	stale := &Build{NixName: "qbittorrent-5.2.4", BuildStatus: statusSuccess, Finished: 1, DrvPath: "/nix/store/bbb-qbittorrent-5.2.4.drv"}
	if got := verdictFor("qbittorrent.aarch64-darwin", darwinPlatform, stale, current); got.Status != "pending" {
		t.Errorf("stale drv must be pending, got %q", got.Status)
	}
	if got := verdictFor("qbittorrent.aarch64-darwin", darwinPlatform, stale, current); got.Version != "5.2.4" {
		t.Errorf("pending verdict should carry the current drv version, got %q", got.Version)
	}
	fresh := &Build{NixName: "qbittorrent-5.2.4", BuildStatus: statusSuccess, Finished: 1, DrvPath: current}
	if got := verdictFor("qbittorrent.aarch64-darwin", darwinPlatform, fresh, current); got.Status != "success" {
		t.Errorf("matching drv must use the build status, got %q", got.Status)
	}
	if got := verdictFor("qbittorrent.aarch64-darwin", darwinPlatform, nil, current); got.Status != "unknown" {
		t.Errorf("no build must be unknown, got %q", got.Status)
	}
}

func TestMergeVerdicts(t *testing.T) {
	a := Verdict{Pins: []PinVerdict{{
		Package: "picard", Class: "darwin", Version: "2.13.3",
		Platforms: []PlatformVerdict{{System: darwinPlatform, Status: "unknown"}},
	}}}
	b := Verdict{Pins: []PinVerdict{{
		Package: "picard", Class: "darwin", Version: "2.13.3",
		Platforms: []PlatformVerdict{{System: darwinPlatform, Status: "success"}},
	}}}
	merged, err := mergeVerdictsFiles(t, a, b)
	if err != nil {
		t.Fatal(err)
	}
	if len(merged.Pins) != 1 {
		t.Fatalf("merged %d pins, want 1", len(merged.Pins))
	}
	if !merged.Pins[0].Green {
		t.Error("pin with a success verdict must be green after merge")
	}

	c := Verdict{Pins: []PinVerdict{{
		Package: "picard", Class: "darwin", Version: "2.13.3",
		Platforms: []PlatformVerdict{{System: darwinPlatform, Status: "failed"}},
	}}}
	merged, err = mergeVerdictsFiles(t, b, c)
	if err != nil {
		t.Fatal(err)
	}
	if merged.Pins[0].Green {
		t.Error("pin with any failed verdict must not be green")
	}
}

func mergeVerdictsFiles(t *testing.T, vs ...Verdict) (Verdict, error) {
	t.Helper()
	dir := t.TempDir()
	var files []string
	for i, v := range vs {
		data, err := json.Marshal(v)
		if err != nil {
			return Verdict{}, err
		}
		f := dir + "/v" + string(rune('a'+i)) + ".json"
		if err := os.WriteFile(f, data, 0o644); err != nil {
			return Verdict{}, err
		}
		files = append(files, f)
	}
	return mergeVerdicts(files)
}

func TestApplyVerdicts(t *testing.T) {
	pins := PinSets{
		Darwin: map[string]Pin{"picard": {Version: "2.13.3"}},
		Nixos:  map[string]Pin{"calibre": {Version: "9.14.0"}},
	}
	v := Verdict{
		Pins: []PinVerdict{
			{Package: "picard", Class: "darwin", Green: true},
			{Package: "calibre", Class: "nixos", Green: false},
		},
		Closures: []ClosureVerdict{{
			Host: "stronghold", System: linuxPlatform, Package: "foo",
			Status: "failed", LastGood: "1.2.3", BuildURL: "https://hydra.nixos.org/build/1",
		}},
	}
	changed, report, err := applyVerdicts(pins, v)
	if err != nil {
		t.Fatal(err)
	}
	if !changed {
		t.Fatal("expected changes")
	}
	if _, ok := pins.Darwin["picard"]; ok {
		t.Error("green pin picard must be dropped")
	}
	if _, ok := pins.Nixos["calibre"]; !ok {
		t.Error("red pin calibre must stay")
	}
	foo := pins.Nixos["foo"]
	if foo.Version != "1.2.3" {
		t.Errorf("foo pinned at %q, want 1.2.3", foo.Version)
	}
	if !strings.Contains(report, "picard") || !strings.Contains(report, "foo@1.2.3") {
		t.Errorf("report missing details:\n%s", report)
	}
}

func TestStripVersion(t *testing.T) {
	if got := stripVersion("picard-3.0.2", "picard.aarch64-darwin"); got != "3.0.2" {
		t.Errorf("stripVersion = %q, want 3.0.2", got)
	}
	if got := stripVersion("weird-name", "picard.aarch64-darwin"); got != "weird-name" {
		t.Errorf("stripVersion fallback = %q", got)
	}
}

func TestRenderReportModes(t *testing.T) {
	v := Verdict{Pins: []PinVerdict{{
		Package: "picard", Class: "darwin", Version: "2.13.3",
		Platforms: []PlatformVerdict{{System: darwinPlatform, Status: "pending"}},
	}}}
	plain := renderReport(v, false)
	if strings.Contains(plain, "](http") || strings.Contains(plain, "| ---") {
		t.Errorf("plain mode must have no markdown links/tables:\n%s", plain)
	}
	if !strings.Contains(plain, "⏳ pending") {
		t.Errorf("plain mode missing status:\n%s", plain)
	}
	md := renderReport(v, true)
	if !strings.Contains(md, "[pending](https://hydra.nixos.org/job/nixpkgs/unstable/picard.aarch64-darwin)") {
		t.Errorf("markdown mode missing linked status:\n%s", md)
	}
	if !strings.Contains(md, "| ---") {
		t.Errorf("markdown mode missing table separators:\n%s", md)
	}
}

func TestParseFailedDrvs(t *testing.T) {
	log := `build flags: -j8
error: builder for '/nix/store/abc-qbittorrent-5.2.4.drv' failed with exit code 1;
       another line /nix/store/def-notafailure-1.0.drv ignored
error: 1 dependencies of derivation '/nix/store/ghi-darwin-system-26.11.drv' failed to build
error: Cannot build '/nix/store/jkl-protonup-rs-0.15.1.drv'.
       Reason: builder failed with exit code 101.
error: Cannot build '/nix/store/mno-system-path.drv'.
       Reason: 1 dependency failed.
error: Cannot build '/nix/store/pqr-nixos-system-26.11.drv'.
       Reason: 1 dependency failed.
note: keeping build directory '/nix/store/xyz-keepme-2.0.drv'`
	got := parseFailedDrvs(log)
	want := []string{"/nix/store/abc-qbittorrent-5.2.4.drv", "/nix/store/ghi-darwin-system-26.11.drv", "/nix/store/jkl-protonup-rs-0.15.1.drv"}
	if len(got) != len(want) {
		t.Fatalf("parseFailedDrvs = %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("parseFailedDrvs[%d] = %q, want %q", i, got[i], want[i])
		}
	}
}

func TestPinFromVerdict(t *testing.T) {
	pins := PinSets{Nixos: map[string]Pin{"calibre": {Version: "9.14.0"}}}
	v := Verdict{Closures: []ClosureVerdict{
		{Host: "stronghold", System: linuxPlatform, Package: "foo", Status: "failed",
			Version: "1.2.3", LastGood: "1.1.0", BuildURL: "https://hydra.nixos.org/build/1"},
		{Host: "stronghold", System: linuxPlatform, Package: "calibre", Status: "failed",
			Version: "9.16.0", LastGood: "9.15.0"},
	}}
	changed, report := pinFromVerdict(pins, v)
	if !changed {
		t.Fatal("expected changes")
	}
	if pins.Nixos["foo"].Version != "1.1.0" {
		t.Errorf("foo pinned at %q, want 1.1.0", pins.Nixos["foo"].Version)
	}
	if _, ok := pins.Nixos["calibre"]; !ok {
		t.Error("already-pinned calibre must be left alone")
	}
	if !strings.Contains(report, "already pinned") {
		t.Errorf("report must note the already-pinned package:\n%s", report)
	}
}
