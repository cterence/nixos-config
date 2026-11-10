package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"regexp"
	"strings"
)

// pinCmd pins the packages whose derivations failed an actual build: the
// failing drv is extracted from the CI build log, the last good version is
// taken from Hydra's history, and an automerge PR (or working-tree edit)
// delivers the pin. A failed build is itself the verdict — no Hydra signal
// needed for the *current* drv.
func cmdPin(args []string) int {
	fs := flag.NewFlagSet("pin", flag.ContinueOnError)
	flake := fs.String("flake", ".", "flake to read pins from")
	pr := fs.Bool("pr", false, "push branch and open/update an automerge PR")
	preview := fs.Bool("preview", false, "show what would change, write nothing")
	system := fs.String("system", "", "platform the failed build ran on (x86_64-linux, aarch64-darwin)")
	var logs pathFlags
	fs.Var(&logs, "from-log", "CI build log to extract failing drvs from, repeatable")
	verdictFile := fs.String("from-verdict", "", "check verdict JSON whose red closure packages to pin")
	if err := fs.Parse(args); err != nil {
		return 2
	}
	if *system == "" && *verdictFile == "" {
		fmt.Fprintln(os.Stderr, "pinned-sweep: pin requires --system (with --from-log) or --from-verdict")
		return 2
	}

	hydra := NewHydra()
	pins, err := loadPins(*flake)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}

	var b strings.Builder
	changed := false

	if *verdictFile != "" {
		data, err := os.ReadFile(*verdictFile)
		if err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
		var v Verdict
		if err := json.Unmarshal(data, &v); err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep: parsing verdict:", err)
			return 1
		}
		c, report := pinFromVerdict(pins, v)
		changed = changed || c
		b.WriteString(report)
	}

	for _, log := range logs {
		data, err := os.ReadFile(log)
		if err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
		drvs := parseFailedDrvs(string(data))
		if len(drvs) == 0 {
			fmt.Fprintf(os.Stderr, "no failing derivations found in %s\n", log)
			continue
		}
		for _, drv := range drvs {
			pkg, version := drvPkg(drv)
			if pkg == "" {
				continue
			}
			class := "nixos"
			if *system == darwinPlatform {
				class = "darwin"
			}
			set := pins.Class(class)
			job := pkg + "." + *system
			fmt.Fprintf(os.Stderr, "%s ...", job)
			lastGood, build, err := hydra.LastGood(job, 25)
			if err != nil {
				fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
				return 1
			}
			if existing, ok := set[pkg]; ok {
				if updated, retargeted := retargetPin(existing, lastGood, build); retargeted {
					updated.Reason = fmt.Sprintf("%s fails on %s (deps relocked without a version bump; frozen to the last good nixpkgs revision%s)",
						version, *system, buildRef(build))
					set[pkg] = updated
					changed = true
					fmt.Fprintf(&b, "Froze pin %s at %s to nixpkgs revision %s on %s (deps drifted inside the version).\n",
						pkg, updated.Version, updated.Revision, class)
				} else if existing.Revision != "" {
					fmt.Fprintf(&b, "%s is pinned at %s (nixpkgs revision %s) on %s and still fails; manual fix needed.\n",
						pkg, existing.Version, existing.Revision, class)
				} else {
					fmt.Fprintf(&b, "%s is already pinned at %s on %s and still fails; manual fix needed.\n",
						pkg, existing.Version, class)
				}
				continue
			}
			if lastGood == "" {
				fmt.Fprintf(os.Stderr, " no good version found\n")
				fmt.Fprintf(&b, "Cannot pin %s (%s): no last good version in Hydra history; manual fix needed.\n",
					pkg, *system)
				continue
			}
			fmt.Fprintf(os.Stderr, " pinning %s\n", lastGood)
			set[pkg] = Pin{
				Version: lastGood,
				Reason: fmt.Sprintf("%s fails on %s (auto-pinned after failed build%s)",
					version, *system, buildRef(build)),
			}
			changed = true
			fmt.Fprintf(&b, "Pinned %s at %s on %s (was %s).\n", pkg, lastGood, class, version)
		}
	}

	if b.Len() > 0 {
		fmt.Print(b.String())
	}
	if !changed {
		fmt.Println("Nothing to pin.")
		return 0
	}

	if *preview {
		fmt.Print(b.String())
		fmt.Println("Preview only — rerun without --preview to apply.")
		return 0
	}

	if err := writePins(*flake, pins); err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}
	fmt.Print(b.String())

	if *pr {
		if err := openPR(b.String()); err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
	} else {
		fmt.Println("modules/pins.nix updated in the working tree; commit when satisfied.")
	}
	return 0
}

func buildRef(build *Build) string {
	if build == nil {
		return ""
	}
	return ", see " + build.URL()
}

// retargetPin freezes a pin that already matches the last good version but
// still fails: same version still red on Hydra means nixpkgs relocked the
// package's deps under the same version, and the version pin tracks the
// broken rebuild. Freezing to the last good build's revision pins the
// derivation that actually built green.
func retargetPin(existing Pin, lastGood string, build *Build) (Pin, bool) {
	date := ""
	if build != nil {
		date = build.UTCDate()
	}
	if lastGood == "" || lastGood != existing.Version || date == "" || date == existing.Revision {
		return existing, false
	}
	existing.Revision = date
	return existing, true
}

// pinFromVerdict pins every red closure package of a check verdict — the
// verdicts already carry the last good version from the Hydra walk.
// Only closures are considered: unpinning is the nightly apply's job.
func pinFromVerdict(pins PinSets, v Verdict) (bool, string) {
	var b strings.Builder
	changed := false
	for _, c := range v.Red() {
		class := "nixos"
		if c.System == darwinPlatform {
			class = "darwin"
		}
		set := pins.Class(class)
		if existing, ok := set[c.Package]; ok {
			fmt.Fprintf(&b, "%s is already pinned at %s on %s and still fails; manual fix needed.\n",
				c.Package, existing.Version, class)
			continue
		}
		if c.LastGood == "" {
			fmt.Fprintf(&b, "Cannot pin %s (%s, %s): no last good version in Hydra history; manual fix needed.\n",
				c.Package, c.Host, c.System)
			continue
		}
		set[c.Package] = Pin{
			Version: c.LastGood,
			Reason: fmt.Sprintf("%s fails on %s (auto-pinned from gate%s)",
				orDash(c.Version), c.System, buildURLSuffix(c.BuildURL)),
		}
		changed = true
		fmt.Fprintf(&b, "Pinned %s at %s on %s (was %s).\n",
			c.Package, c.LastGood, class, orDash(c.Version))
	}
	return changed, b.String()
}

func buildURLSuffix(url string) string {
	if url == "" {
		return ""
	}
	return ", see " + url
}

type pathFlags []string

func (p *pathFlags) String() string { return strings.Join(*p, ",") }

func (p *pathFlags) Set(s string) error {
	*p = append(*p, s)
	return nil
}

var drvPathRe = regexp.MustCompile(`/nix/store/[a-z0-9]+-[^\s'"]+\.drv`)

// parseFailedDrvs extracts the derivations a build failed on: drv paths on
// lines mentioning a failure ("builder for '...drv' failed with exit code"),
// plus "Cannot build '<drv>'" errors whose Reason line says the builder
// itself failed (dependency-only failures are inherited, not the culprit).
func parseFailedDrvs(log string) []string {
	seen := map[string]bool{}
	var out []string
	add := func(drv string) {
		if !seen[drv] {
			seen[drv] = true
			out = append(out, drv)
		}
	}
	lines := strings.Split(log, "\n")
	for i, line := range lines {
		if strings.Contains(line, "Cannot build '") {
			if m := drvPathRe.FindString(line); m != "" {
				reason := ""
				if i+1 < len(lines) {
					reason = lines[i+1]
				}
				if strings.Contains(reason, "builder failed") {
					add(m)
				}
			}
			continue
		}
		if !strings.Contains(line, "failed") {
			continue
		}
		for _, m := range drvPathRe.FindAllString(line, -1) {
			add(m)
		}
	}
	return out
}
