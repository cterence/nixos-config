package main

import (
	"encoding/json"
	"os"
	"strings"
	"testing"
)

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
		`{ inputs, ... }:`,
		`flake.pins = pins;`,
		`darwin = {`,
		`version = "2.13.3";`,
		`tracker = "https://github.com/NixOS/nixpkgs/issues/572435";`,
		`reason = "says \"hi\" \${now}";`,
		`nixos = { };`,
		`flake.overlays.multiverse-pins =`,
		`inputs.multiverse.lib.pinOverlay`,
		`overlay final _prev;`,
	} {
		if !strings.Contains(out, want) {
			t.Errorf("emitPins missing %q in:\n%s", want, out)
		}
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
note: keeping build directory '/nix/store/xyz-keepme-2.0.drv'`
	got := parseFailedDrvs(log)
	want := []string{"/nix/store/abc-qbittorrent-5.2.4.drv", "/nix/store/ghi-darwin-system-26.11.drv"}
	if len(got) != len(want) {
		t.Fatalf("parseFailedDrvs = %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("parseFailedDrvs[%d] = %q, want %q", i, got[i], want[i])
		}
	}
}
