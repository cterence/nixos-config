package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
)

// Platform class -> the Hydra platform its pins must build on.
const (
	linuxPlatform  = "x86_64-linux"
	darwinPlatform = "aarch64-darwin"
)

func platformFor(class string) string {
	if class == "darwin" {
		return darwinPlatform
	}
	return linuxPlatform
}

// Verdict is the stable JSON schema shared by check and apply.
type Verdict struct {
	Pins     []PinVerdict     `json:"pins"`
	Closures []ClosureVerdict `json:"closures,omitempty"`
}

type PinVerdict struct {
	Package   string            `json:"package"`
	Class     string            `json:"class"`
	Version   string            `json:"version"`
	Tracker   string            `json:"tracker,omitempty"`
	Platforms []PlatformVerdict `json:"platforms"`
	Green     bool              `json:"green"`
}

type PlatformVerdict struct {
	System   string `json:"system"`
	Status   string `json:"status"` // success | failed | pending | unknown
	Version  string `json:"version,omitempty"`
	BuildURL string `json:"buildUrl,omitempty"`
}

type ClosureVerdict struct {
	Host     string `json:"host"`
	System   string `json:"system"`
	Package  string `json:"package"`
	Status   string `json:"status"` // failed | success | skipped
	Version  string `json:"version,omitempty"`
	BuildURL string `json:"buildUrl,omitempty"`
	LastGood string `json:"lastGood,omitempty"`
}

// Red reports whether any closure package failed its Hydra build.
func (v Verdict) Red() []ClosureVerdict {
	var red []ClosureVerdict
	for _, c := range v.Closures {
		if c.Status == "failed" {
			red = append(red, c)
		}
	}
	return red
}

func cmdCheck(args []string) int {
	fs := flag.NewFlagSet("check", flag.ContinueOnError)
	flake := fs.String("flake", ".", "flake to read pins from")
	asJSON := fs.Bool("json", false, "print verdict JSON on stdout")
	buildUnknown := fs.Bool("build-unknown", false, "nix-build pins Hydra has no data for, natively")
	var closures closureFlags
	fs.Var(&closures, "closure", "host=attr closure to gate, repeatable")
	if err := fs.Parse(args); err != nil {
		return 2
	}

	hydra := NewHydra()
	pins, err := loadPins(*flake)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}

	v, err := checkPins(hydra, pins, *buildUnknown)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}
	for _, c := range closures {
		cvs, err := checkClosure(hydra, *flake, pins, c.host, c.attr)
		if err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
		v.Closures = append(v.Closures, cvs...)
	}

	if *asJSON {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		if err := enc.Encode(v); err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
	} else {
		fmt.Print(renderReport(v))
	}
	// Red closures fail the gate; red pins are expected (that is why they
	// are pinned) and only reported.
	if len(v.Red()) > 0 {
		return 1
	}
	return 0
}

type closureFlag struct {
	host string
	attr string
}

type closureFlags []closureFlag

func (c *closureFlags) String() string { return "" }

func (c *closureFlags) Set(s string) error {
	host, attr, ok := strings.Cut(s, "=")
	if !ok {
		return fmt.Errorf("--closure wants host=attr, got %q", s)
	}
	*c = append(*c, closureFlag{host, attr})
	return nil
}

// checkPins Hydra-checks every pin on the platform its class needs.
func checkPins(hydra *Hydra, pins PinSets, buildUnknown bool) (Verdict, error) {
	v := Verdict{}
	for _, class := range []struct {
		name string
		pins map[string]Pin
	}{{"darwin", pins.Darwin}, {"nixos", pins.Nixos}} {
		for _, name := range sortedKeys(class.pins) {
			pin := class.pins[name]
			pv := PinVerdict{Package: name, Class: class.name, Version: pin.Version, Tracker: pin.Tracker}
			job := name + "." + platformFor(class.name)
			fmt.Fprintf(os.Stderr, "checking %s (%s)\n", job, pin.Version)
			b, err := hydra.LatestBuild(job)
			if err != nil {
				return v, err
			}
			status := "unknown"
			if b != nil {
				status = b.Status()
				pv.Platforms = append(pv.Platforms, PlatformVerdict{
					System:   platformFor(class.name),
					Status:   status,
					Version:  stripVersion(b.NixName, job),
					BuildURL: b.URL(),
				})
			} else {
				pv.Platforms = append(pv.Platforms, PlatformVerdict{
					System: platformFor(class.name),
					Status: "unknown",
				})
			}
			// Fallback: no Hydra signal, try a real build of the unstable
			// version on the native system.
			if status == "unknown" && buildUnknown {
				if s, err := buildUnstable(name); err != nil {
					fmt.Fprintf(os.Stderr, "build fallback for %s failed: %v\n", name, err)
				} else if s {
					pv.Platforms[0].Status = "success"
					pv.Platforms[0].Version = "unstable (built locally)"
				} else {
					pv.Platforms[0].Status = "failed"
				}
			}
			pv.Green = status == "success"
			v.Pins = append(v.Pins, pv)
		}
	}
	return v, nil
}

// buildUnstable builds a package from current nixos-unstable natively.
func buildUnstable(pkg string) (bool, error) {
	cmd := exec.Command("nix", "build", "--impure", "--no-link",
		"github:NixOS/nixpkgs/nixos-unstable#"+pkg)
	cmd.Env = append(os.Environ(), "NIXPKGS_ALLOW_UNFREE=1")
	cmd.Stdout = os.Stderr
	cmd.Stderr = os.Stderr
	return cmd.Run() == nil, nil
}

var drvRe = regexp.MustCompile(`^\s*/nix/store/[a-z0-9]+-(.+)\.drv$`)

// parseDryRun extracts derivation names from `nix build --dry-run` output,
// deduplicated in order (fetched sections may repeat built drvs).
func parseDryRun(out string) []string {
	seen := map[string]bool{}
	var names []string
	for _, line := range strings.Split(out, "\n") {
		if m := drvRe.FindStringSubmatch(line); m != nil && !seen[m[1]] {
			seen[m[1]] = true
			names = append(names, m[1])
		}
	}
	return names
}

// splitPkgName splits "picard-3.0.2" into ("picard", "3.0.2"). Scoped names
// like "python3.13-foo-1.2" split at the last plausible version separator,
// which keeps the mapping heuristic and lets Hydra 404s skip them.
func splitPkgName(name string) (string, string) {
	i := indexVersionSep(name)
	if i < 0 {
		return name, ""
	}
	return name[:i], name[i+1:]
}

// checkClosure dry-runs a host closure and Hydra-checks every package the
// host would actually build (cache miss). Pinned packages are skipped: their
// Hydra job reflects current unstable, not the pinned version.
func checkClosure(hydra *Hydra, flake string, pins PinSets, host, attr string) ([]ClosureVerdict, error) {
	system := linuxPlatform
	if strings.Contains(attr, "darwinConfigurations") {
		system = darwinPlatform
	}
	class := "nixos"
	if system == darwinPlatform {
		class = "darwin"
	}
	pinned := pins.Class(class)

	fmt.Fprintf(os.Stderr, "dry-running closure %s (%s)\n", host, attr)
	cmd := exec.Command("nix", "build", "--dry-run", "--no-link", flake+"#"+attr)
	var stderr strings.Builder
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		return nil, fmt.Errorf("dry-run %s: %w", attr, err)
	}

	seen := map[string]bool{}
	var out []ClosureVerdict
	for _, drv := range parseDryRun(stderr.String()) {
		pkg, version := splitPkgName(drv)
		if pkg == "" || seen[pkg] || pinned[pkg].Version != "" {
			continue
		}
		seen[pkg] = true
		job := pkg + "." + system
		fmt.Fprintf(os.Stderr, "checking %s\n", job)
		b, err := hydra.LatestBuild(job)
		if err != nil {
			return nil, err
		}
		cv := ClosureVerdict{Host: host, System: system, Package: pkg, Version: version, Status: "skipped"}
		switch {
		case b == nil:
			// Not a Hydra job (local package, scoped attr): no signal, skip.
		case b.Status() == "failed":
			cv.Status = "failed"
			cv.BuildURL = b.URL()
			lastGood, lb, err := hydra.LastGood(job, 25)
			if err != nil {
				return nil, err
			}
			if lastGood == "" && lb != nil {
				lastGood = stripVersion(lb.NixName, job)
			}
			cv.LastGood = lastGood
		default:
			cv.Status = "success"
		}
		out = append(out, cv)
	}
	return out, nil
}
