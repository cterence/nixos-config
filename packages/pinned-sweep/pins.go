package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strings"
)

// Pin is one entry of flake.pins.
type Pin struct {
	Version string `json:"version"`
	Tracker string `json:"tracker"`
	Reason  string `json:"reason"`
}

// PinSets mirrors flake.pins: class (darwin/nixos) -> package -> pin.
type PinSets struct {
	Darwin map[string]Pin `json:"darwin"`
	Nixos  map[string]Pin `json:"nixos"`
}

// Class returns the pin set for a host class name.
func (p PinSets) Class(class string) map[string]Pin {
	if class == "darwin" {
		return p.Darwin
	}
	return p.Nixos
}

// loadPins reads flake.pins via nix eval.
func loadPins(flake string) (PinSets, error) {
	out, err := exec.Command("nix", "eval", "--json", flake+"#pins").Output()
	if err != nil {
		return PinSets{}, fmt.Errorf("nix eval %s#pins: %w", flake, err)
	}
	var pins PinSets
	if err := json.Unmarshal(out, &pins); err != nil {
		return PinSets{}, fmt.Errorf("parsing flake.pins: %w", err)
	}
	if pins.Darwin == nil {
		pins.Darwin = map[string]Pin{}
	}
	if pins.Nixos == nil {
		pins.Nixos = map[string]Pin{}
	}
	return pins, nil
}

// emitPins renders modules/pins.nix. Deterministic: keys sorted, fixed style.
func emitPins(p PinSets) string {
	var b strings.Builder
	b.WriteString(`# Single source of truth for multiverse pins. Machine-managed by
# ` + "`packages/pinned-sweep`" + ` (` + "`pinned-sweep apply`" + `) — it regenerates this file.
# Each pin: version to pin, upstream nixpkgs tracker, and why.
{
  flake.pins = {
`)
	for _, class := range []struct {
		name string
		pins map[string]Pin
	}{{"darwin", p.Darwin}, {"nixos", p.Nixos}} {
		if len(class.pins) == 0 {
			fmt.Fprintf(&b, "    %s = { };\n", class.name)
			continue
		}
		fmt.Fprintf(&b, "    %s = {\n", class.name)
		for _, name := range sortedKeys(class.pins) {
			pin := class.pins[name]
			fmt.Fprintf(&b, "      %s = {\n", name)
			fmt.Fprintf(&b, "        version = %s;\n", nixStr(pin.Version))
			fmt.Fprintf(&b, "        tracker = %s;\n", nixStr(pin.Tracker))
			fmt.Fprintf(&b, "        reason = %s;\n", nixStr(pin.Reason))
			b.WriteString("      };\n")
		}
		b.WriteString("    };\n")
	}
	b.WriteString("  };\n}\n")
	return b.String()
}

func sortedKeys[T any](m map[string]T) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

// nixStr quotes a Go string as a Nix string literal.
func nixStr(s string) string {
	r := strings.NewReplacer(`\`, `\\`, `"`, `\"`, `${`, `\${`)
	return `"` + r.Replace(s) + `"`
}

// writePins regenerates modules/pins.nix relative to the flake root.
func writePins(flake string, p PinSets) error {
	path := strings.TrimSuffix(flake, "/") + "/modules/pins.nix"
	return os.WriteFile(path, []byte(emitPins(p)), 0o644)
}
