package main

import (
	"fmt"
	"strings"
	"time"
)

const hydraBaseURL = "https://hydra.nixos.org"

// renderReport renders the verdict as a markdown report: stdout locally,
// step summary / PR body in CI.
func renderReport(v Verdict) string {
	var b strings.Builder
	fmt.Fprintf(&b, "# Pinned package sweep — %s\n\n", time.Now().Format("2006-01-02"))

	if len(v.Pins) == 0 && len(v.Closures) == 0 {
		b.WriteString("No pins and no closure checks to report.\n")
		return b.String()
	}

	if len(v.Pins) > 0 {
		b.WriteString("## Pins\n\n")
		b.WriteString("| Package | Class | Pinned | Unstable | Status |\n")
		b.WriteString("| --- | --- | --- | --- | --- |\n")
		for _, p := range v.Pins {
			for _, pl := range p.Platforms {
				jobURL := hydraJobURL(p.Package, pl.System)
				status := statusCell(pl.Status, pl.BuildURL, jobURL)
				fmt.Fprintf(&b, "| %s | %s | %s | %s | %s |\n",
					p.Package, p.Class, p.Version, orDash(pl.Version), status)
			}
			if len(p.Platforms) == 0 {
				fmt.Fprintf(&b, "| %s | %s | %s | — | ❔ no Hydra data |\n", p.Package, p.Class, p.Version)
			}
		}
		b.WriteString("\n")
		writePinSummary(&b, v)
	}

	if len(v.Closures) > 0 {
		b.WriteString("## Closure gate\n\n")
		b.WriteString("| Host | Package | Version | Status | Last good |\n")
		b.WriteString("| --- | --- | --- | --- | --- |\n")
		skipped := 0
		for _, c := range v.Closures {
			if c.Status == "skipped" {
				skipped++
				continue
			}
			status := statusCell(c.Status, c.BuildURL, "")
			fmt.Fprintf(&b, "| %s | %s | %s | %s | %s |\n",
				c.Host, c.Package, orDash(c.Version), status, orDash(c.LastGood))
		}
		if skipped > 0 {
			fmt.Fprintf(&b, "\n%d closure packages skipped (no Hydra verdict for their derivation: local packages, wrappers, scoped attrs).\n", skipped)
		}
		b.WriteString("\n")
	}

	b.WriteString("Pins live in `modules/pins.nix`; `pinned-sweep apply` drops green pins and pins red closure packages at their last good version.\n")
	return b.String()
}

// writePinSummary groups pins by verdict and says what each means.
func writePinSummary(b *strings.Builder, v Verdict) {
	byStatus := map[string][]string{}
	for _, p := range v.Pins {
		status := "unknown"
		if len(p.Platforms) > 0 {
			status = p.Platforms[0].Status
		}
		byStatus[status] = append(byStatus[status], p.Package)
	}
	if names := byStatus["success"]; len(names) > 0 {
		fmt.Fprintf(b, "Safe to unpin: %s.\n", strings.Join(names, ", "))
	}
	if names := byStatus["pending"]; len(names) > 0 {
		fmt.Fprintf(b, "Pending — Hydra hasn't delivered a verdict for the derivation current unstable builds yet; nothing to do, rerun later or watch the job links: %s.\n",
			strings.Join(names, ", "))
	}
	if names := byStatus["failed"]; len(names) > 0 {
		fmt.Fprintf(b, "Failing on unstable, pin stays: %s.\n", strings.Join(names, ", "))
	}
	if names := byStatus["unknown"]; len(names) > 0 {
		fmt.Fprintf(b, "No Hydra data (unfree or not built by Hydra), needs the build fallback or a manual call: %s.\n", strings.Join(names, ", "))
	}
	b.WriteString("\n")
}

func hydraJobURL(pkg, system string) string {
	return fmt.Sprintf("%s/job/nixpkgs/unstable/%s.%s", hydraBaseURL, pkg, system)
}

func statusCell(status, buildURL, jobURL string) string {
	switch status {
	case "success":
		return "✅ green"
	case "failed":
		if buildURL != "" {
			return fmt.Sprintf("❌ [failed](%s)", buildURL)
		}
		return "❌ failed"
	case "pending":
		return fmt.Sprintf("⏳ [pending](%s) — Hydra hasn't built this derivation yet", jobURL)
	default:
		if jobURL != "" {
			return fmt.Sprintf("❔ [no Hydra data](%s)", jobURL)
		}
		return "❔ no Hydra data"
	}
}

func orDash(s string) string {
	if s == "" {
		return "—"
	}
	return s
}
