package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const sweepBranch = "pinned-sweep/sweep"

func cmdApply(args []string) int {
	fs := flag.NewFlagSet("apply", flag.ContinueOnError)
	flake := fs.String("flake", ".", "flake to read pins from")
	pr := fs.Bool("pr", false, "push branch and open/update an automerge PR")
	preview := fs.Bool("preview", false, "show what would change, write nothing")
	var verdicts verdictFlags
	fs.Var(&verdicts, "verdict", "check verdict JSON to merge, repeatable")
	if err := fs.Parse(args); err != nil {
		return 2
	}

	hydra := NewHydra()
	pins, err := loadPins(*flake)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}

	var v Verdict
	if len(verdicts) == 0 {
		v, err = checkPins(hydra, pins, false)
		if err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
	} else {
		v, err = mergeVerdicts(verdicts)
		if err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
	}

	changed, report, err := applyVerdicts(pins, v)
	if err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}

	if !changed {
		fmt.Println("Nothing to change.")
		return 0
	}

	if *preview {
		fmt.Print(report)
		fmt.Println("Preview only — rerun without --preview to apply.")
		return 0
	}

	if err := writePins(*flake, pins); err != nil {
		fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
		return 1
	}
	fmt.Print(report)

	if *pr {
		if err := openPR(report); err != nil {
			fmt.Fprintln(os.Stderr, "pinned-sweep:", err)
			return 1
		}
	} else {
		fmt.Println("modules/pins.nix updated in the working tree; commit when satisfied.")
	}
	return 0
}

type verdictFlags []string

func (v *verdictFlags) String() string { return strings.Join(*v, ",") }

func (v *verdictFlags) Set(s string) error {
	*v = append(*v, s)
	return nil
}

// mergeVerdicts loads verdict files and merges them per pin+platform: a pin
// is green only if every needed platform has a success and none has a
// failure or pending build anywhere.
func mergeVerdicts(files []string) (Verdict, error) {
	var merged Verdict
	byPin := map[string]int{}
	for _, f := range files {
		data, err := os.ReadFile(f)
		if os.IsNotExist(err) {
			fmt.Fprintf(os.Stderr, "pinned-sweep: verdict %s not found, skipping\n", f)
			continue
		}
		if err != nil {
			return merged, fmt.Errorf("reading verdict %s: %w", f, err)
		}
		var v Verdict
		if err := json.Unmarshal(data, &v); err != nil {
			return merged, fmt.Errorf("parsing verdict %s: %w", f, err)
		}
		for _, p := range v.Pins {
			if idx, ok := byPin[p.Package]; ok {
				merged.Pins[idx].Platforms = append(merged.Pins[idx].Platforms, p.Platforms...)
			} else {
				byPin[p.Package] = len(merged.Pins)
				merged.Pins = append(merged.Pins, p)
			}
		}
		merged.Closures = append(merged.Closures, v.Closures...)
	}
	for i := range merged.Pins {
		merged.Pins[i].Green = greenPlatforms(merged.Pins[i].Platforms)
	}
	return merged, nil
}

// greenPlatforms: every system must have a success verdict and none may
// have a failure or pending build. A success supersedes an unknown from an
// earlier verdict file (the fallback build is stronger evidence).
func greenPlatforms(platforms []PlatformVerdict) bool {
	if len(platforms) == 0 {
		return false
	}
	bySystem := map[string]bool{} // system -> has success
	for _, pl := range platforms {
		switch pl.Status {
		case "failed", "pending":
			return false
		case "success":
			bySystem[pl.System] = true
		}
	}
	return len(bySystem) > 0
}

// applyVerdicts mutates pins in place: drops green pins, adds pins for red
// closure packages at their last good version. Returns whether anything
// changed and the human report.
func applyVerdicts(pins PinSets, v Verdict) (bool, string, error) {
	var b strings.Builder
	changed := false

	var dropped, added []string
	for _, p := range v.Pins {
		if !p.Green {
			continue
		}
		set := pins.Class(p.Class)
		if _, ok := set[p.Package]; !ok {
			continue
		}
		delete(set, p.Package)
		dropped = append(dropped, p.Package)
		changed = true
	}

	for _, c := range v.Red() {
		class := "nixos"
		if c.System == darwinPlatform {
			class = "darwin"
		}
		set := pins.Class(class)
		if c.LastGood == "" {
			fmt.Fprintf(&b, "Cannot pin %s (%s, %s): no last good version found.\n",
				c.Package, c.Host, c.System)
			continue
		}
		if existing, ok := set[c.Package]; ok {
			fmt.Fprintf(&b, "%s is already pinned at %s on %s and still fails; manual fix needed.\n",
				c.Package, existing.Version, class)
			continue
		}
		reason := fmt.Sprintf("fails on %s (see %s)", c.System, c.BuildURL)
		set[c.Package] = Pin{Version: c.LastGood, Reason: reason}
		added = append(added, fmt.Sprintf("%s@%s (%s)", c.Package, c.LastGood, class))
		changed = true
	}

	if len(dropped) > 0 {
		fmt.Fprintf(&b, "Dropped pins (green on unstable): %s.\n", strings.Join(dropped, ", "))
	}
	if len(added) > 0 {
		fmt.Fprintf(&b, "Added pins (last good version): %s.\n", strings.Join(added, ", "))
	}
	return changed, b.String(), nil
}

// openPR commits the pins change, pushes the sweep branch and creates or
// updates the automerge PR.
func openPR(report string) error {
	branch := sweepBranch
	if out, err := exec.Command("git", "rev-parse", "--abbrev-ref", "HEAD").Output(); err == nil && strings.TrimSpace(string(out)) == branch {
		// already on the branch from a previous run
	} else if err := exec.Command("git", "checkout", "-B", branch, "HEAD").Run(); err != nil {
		return fmt.Errorf("checkout %s: %w", branch, err)
	}

	title := "chore(pins): sweep"
	bodyFile, err := os.CreateTemp("", "pins-pr-body-*.md")
	if err != nil {
		return err
	}
	defer os.Remove(bodyFile.Name())
	if _, err := bodyFile.WriteString(report); err != nil {
		return err
	}
	bodyFile.Close()

	if err := exec.Command("git", "add", "modules/pins.nix").Run(); err != nil {
		return fmt.Errorf("staging pins: %w", err)
	}
	if err := exec.Command("git", "commit", "-m", title).Run(); err != nil {
		// Nothing to commit means the tree already matches: fine.
		if _, ok := err.(*exec.ExitError); !ok {
			return fmt.Errorf("commit: %w", err)
		}
	}
	remote := pushURL()
	// The sweep branch is bot-owned and rewritten from main each run.
	if err := exec.Command("git", "push", "--force", remote, "HEAD:refs/heads/"+branch).Run(); err != nil {
		return fmt.Errorf("push: %w", err)
	}

	ghArgs := []string{"pr", "create", "--head", branch, "--title", title,
		"--body-file", bodyFile.Name(), "--label", "automated", "--label", "automerge"}
	cmd := exec.Command("gh", ghArgs...)
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		// A PR for this branch may already exist; update its body instead.
		upd := exec.Command("gh", "pr", "view", branch, "--json", "url", "--jq", ".url")
		if upd.Run() != nil {
			return fmt.Errorf("gh pr create: %w", err)
		}
		edit := exec.Command("gh", "pr", "edit", branch, "--body-file", bodyFile.Name())
		edit.Stderr = os.Stderr
		return edit.Run()
	}
	return nil
}

// pushURL builds an authenticated push URL from GH_TOKEN (app token in CI).
func pushURL() string {
	repo := os.Getenv("GITHUB_REPOSITORY")
	if repo == "" {
		return "origin"
	}
	token := os.Getenv("GH_TOKEN")
	if token == "" {
		return "origin"
	}
	return "https://x-access-token:" + token + "@github.com/" + repo + ".git"
}
