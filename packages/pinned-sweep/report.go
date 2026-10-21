package main

import (
	"fmt"
	"strings"
	"time"
)

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
		b.WriteString("| Package | Class | Pinned | Platform | Unstable | Status |\n")
		b.WriteString("| --- | --- | --- | --- | --- | --- |\n")
		for _, p := range v.Pins {
			for _, pl := range p.Platforms {
				status := statusCell(pl.Status, pl.BuildURL)
				fmt.Fprintf(&b, "| %s | %s | %s | %s | %s | %s |\n",
					p.Package, p.Class, p.Version, pl.System, orDash(pl.Version), status)
			}
			if len(p.Platforms) == 0 {
				fmt.Fprintf(&b, "| %s | %s | %s | — | — | ❔ unknown |\n", p.Package, p.Class, p.Version)
			}
		}
		b.WriteString("\n")
		green := greenPins(v)
		if len(green) > 0 {
			fmt.Fprintf(&b, "Green on every needed platform, safe to unpin: %s.\n",
				strings.Join(green, ", "))
		}
		b.WriteString("\n")
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
			status := statusCell(c.Status, c.BuildURL)
			fmt.Fprintf(&b, "| %s | %s | %s | %s | %s |\n",
				c.Host, c.Package, orDash(c.Version), status, orDash(c.LastGood))
		}
		if skipped > 0 {
			fmt.Fprintf(&b, "\n%d closure packages skipped (no Hydra job: local packages, wrappers, scoped attrs).\n", skipped)
		}
		b.WriteString("\n")
	}

	b.WriteString("Pins live in `modules/pins.nix`; `pinned-sweep apply` drops green pins and pins red closure packages at their last good version.\n")
	return b.String()
}

func statusCell(status, url string) string {
	switch status {
	case "success":
		return "✅ green"
	case "failed":
		if url != "" {
			return fmt.Sprintf("❌ [failed](%s)", url)
		}
		return "❌ failed"
	case "pending":
		return "⏳ pending"
	default:
		return "❔ no Hydra data"
	}
}

func orDash(s string) string {
	if s == "" {
		return "—"
	}
	return s
}

// greenPins lists pins green on every platform verdict.
func greenPins(v Verdict) []string {
	var out []string
	for _, p := range v.Pins {
		ok := len(p.Platforms) > 0
		for _, pl := range p.Platforms {
			if pl.Status != "success" {
				ok = false
			}
		}
		if ok {
			out = append(out, p.Package)
		}
	}
	return out
}
