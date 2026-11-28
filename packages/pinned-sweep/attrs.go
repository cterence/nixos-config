package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// attrInfo is the cheap metadata of a nixpkgs attribute: enough to tell which
// derivation it builds without instantiating it.
type attrInfo struct {
	Pname   string `json:"pname"`
	Version string `json:"version"`
}

// attrCandidates lists the nixpkgs attribute names a drv pname may live
// under: unchanged, and camelCased (the usual nixpkgs spelling, so
// glibc-locales is glibcLocales).
func attrCandidates(pkg string) []string {
	cands := []string{pkg}
	if camel := camelCase(pkg); camel != pkg {
		cands = append(cands, camel)
	}
	return cands
}

func camelCase(s string) string {
	parts := strings.Split(s, "-")
	var b strings.Builder
	b.WriteString(parts[0])
	for _, p := range parts[1:] {
		if p == "" {
			continue
		}
		b.WriteString(strings.ToUpper(p[:1]))
		b.WriteString(p[1:])
	}
	return b.String()
}

// resolveAttrs looks candidate attribute names up in the nixpkgs release
// Hydra builds, one batched eval per chunk. Unknown names and anything that
// fails to evaluate are simply absent from the result.
func resolveAttrs(ctx context.Context, system string, cands []string) map[string]attrInfo {
	out := map[string]attrInfo{}
	const chunk = 64
	for i := 0; i < len(cands); i += chunk {
		end := min(i+chunk, len(cands))
		infos, err := resolveChunk(ctx, system, cands[i:end])
		if err != nil {
			// Unresolved attrs are skipped, never guessed: a wrong name
			// only ever yields a Hydra 404.
			fmt.Fprintf(os.Stderr, "resolving %s attrs failed: %v\n", system, err)
			continue
		}
		for k, v := range infos {
			out[k] = v
		}
	}
	return out
}

func resolveChunk(ctx context.Context, system string, cands []string) (map[string]attrInfo, error) {
	quoted := make([]string, len(cands))
	for i, c := range cands {
		quoted[i] = fmt.Sprintf("%q", c)
	}
	expr := fmt.Sprintf(`let
  np = (builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable").legacyPackages.%s;
  meta = n: builtins.tryEval { pname = np.${n}.pname or ""; version = np.${n}.version or ""; };
in builtins.listToAttrs (map (n:
  { name = n;
    value = if np ? ${n} && (np.${n}.type or "") == "derivation" && (meta n).success
            then (meta n).value
            else null; }) [ %s ])`, system, strings.Join(quoted, " "))

	cmd := exec.CommandContext(ctx, "nix", "eval", "--impure", "--json",
		"--extra-experimental-features", "nix-command flakes", "--expr", expr)
	var stderr strings.Builder
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("%w: %s", err, strings.TrimSpace(stderr.String()))
	}
	raw := map[string]*attrInfo{}
	if err := json.Unmarshal(out, &raw); err != nil {
		return nil, fmt.Errorf("parsing nix eval output: %w", err)
	}
	infos := map[string]attrInfo{}
	for k, v := range raw {
		if v != nil {
			infos[k] = *v
		}
	}
	return infos, nil
}

// resolveJobAttrs fills in the nixpkgs attribute each job's derivation came
// from. A closure derivation with no attribute is not a Hydra job at all, so
// it must never be queried.
func resolveJobAttrs(ctx context.Context, system string, jobs []job) {
	want := make([]string, 0, 2*len(jobs))
	seen := map[string]bool{}
	for _, j := range jobs {
		for _, c := range attrCandidates(j.pkg) {
			if !seen[c] {
				seen[c] = true
				want = append(want, c)
			}
		}
	}
	infos := resolveAttrs(ctx, system, want)
	for i := range jobs {
		for _, c := range attrCandidates(jobs[i].pkg) {
			if info, ok := infos[c]; ok && attrMatches(info, jobs[i]) {
				jobs[i].attr = c
				break
			}
		}
	}
}

// attrMatches reports whether a nixpkgs attribute builds this very package:
// same pname, and a version the drv name agrees with (drv versions carry
// extra suffixes, e.g. glibc-locales 2.44 vs 2.44-57).
func attrMatches(info attrInfo, j job) bool {
	if info.Pname != "" && info.Pname != j.pkg {
		return false
	}
	return info.Version == "" || strings.HasPrefix(j.version, info.Version)
}

// isGranularCargoDrv reports whether a drv is a per-crate unit of a granular
// cargo build. Those are build inputs, never top-level Hydra jobs — a whole
// closure yields hundreds of them.
func isGranularCargoDrv(pkg string) bool {
	return strings.HasPrefix(pkg, "cargo-src-") || strings.HasPrefix(pkg, "cargo-package-")
}
