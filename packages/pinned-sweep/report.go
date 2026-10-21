package main

import (
	"fmt"
	"os"
	"strings"
	"text/tabwriter"
	"time"
)

const hydraBaseURL = "https://hydra.nixos.org"

// isTTY reports whether the file is a character device (a terminal).
func isTTY(f *os.File) bool {
	fi, err := f.Stat()
	if err != nil {
		return false
	}
	return fi.Mode()&os.ModeCharDevice != 0
}

// renderReport renders the verdict for humans (plain, aligned) or for
// markdown sinks (step summary, PR body: links, tables).
func renderReport(v Verdict, markdown bool) string {
	var b strings.Builder
	fmt.Fprintf(&b, "Pinned package sweep — %s\n\n", time.Now().Format("2006-01-02"))

	if len(v.Pins) == 0 && len(v.Closures) == 0 {
		b.WriteString("No pins and no closure checks to report.\n")
		return b.String()
	}

	if len(v.Pins) > 0 {
		if markdown {
			b.WriteString("## Pins\n\n")
		} else {
			b.WriteString("Pins\n\n")
		}
		w := tabwriter.NewWriter(&b, 2, 4, 2, ' ', 0)
		if markdown {
			fmt.Fprintln(w, "| Package\t| Class\t| Pinned\t| Unstable\t| Status\t|")
			fmt.Fprintln(w, "| ---\t| ---\t| ---\t| ---\t| ---\t|")
		} else {
			fmt.Fprintln(w, "Package\tClass\tPinned\tUnstable\tStatus")
		}
		for _, p := range v.Pins {
			for _, pl := range p.Platforms {
				jobURL := hydraJobURL(p.Package, pl.System)
				status := statusCell(pl.Status, pl.BuildURL, jobURL, markdown)
				if markdown {
					fmt.Fprintf(w, "| %s\t| %s\t| %s\t| %s\t| %s\t|\n",
						p.Package, p.Class, p.Version, orDash(pl.Version), status)
				} else {
					fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\n",
						p.Package, p.Class, p.Version, orDash(pl.Version), status)
				}
			}
			if len(p.Platforms) == 0 {
				if markdown {
					fmt.Fprintf(w, "| %s\t| %s\t| %s\t| —\t| ❔ no Hydra data\t|\n", p.Package, p.Class, p.Version)
				} else {
					fmt.Fprintf(w, "%s\t%s\t%s\t—\t❔ no Hydra data\n", p.Package, p.Class, p.Version)
				}
			}
		}
		w.Flush()
		b.WriteString("\n")
		writePinSummary(&b, v)
	}

	if len(v.Closures) > 0 {
		if markdown {
			b.WriteString("## Closure gate\n\n")
		} else {
			b.WriteString("Closure gate\n\n")
		}
		w := tabwriter.NewWriter(&b, 2, 4, 2, ' ', 0)
		if markdown {
			fmt.Fprintln(w, "| Host\t| Package\t| Version\t| Status\t| Last good\t|")
			fmt.Fprintln(w, "| ---\t| ---\t| ---\t| ---\t| ---\t|")
		} else {
			fmt.Fprintln(w, "Host\tPackage\tVersion\tStatus\tLast good")
		}
		skipped := 0
		for _, c := range v.Closures {
			if c.Status == "skipped" {
				skipped++
				continue
			}
			status := statusCell(c.Status, c.BuildURL, "", markdown)
			if markdown {
				fmt.Fprintf(w, "| %s\t| %s\t| %s\t| %s\t| %s\t|\n",
					c.Host, c.Package, orDash(c.Version), status, orDash(c.LastGood))
			} else {
				fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\n",
					c.Host, c.Package, orDash(c.Version), status, orDash(c.LastGood))
			}
		}
		w.Flush()
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
		fmt.Fprintf(b, "Pending — Hydra hasn't delivered a verdict for the derivation current unstable builds yet; nothing to do, rerun later: %s.\n",
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

func statusCell(status, buildURL, jobURL string, markdown bool) string {
	link := func(text, url string) string {
		if markdown && url != "" {
			return fmt.Sprintf("[%s](%s)", text, url)
		}
		return text
	}
	switch status {
	case "success":
		return "✅ green"
	case "failed":
		return "❌ " + link("failed", buildURL)
	case "pending":
		return "⏳ " + link("pending", jobURL)
	default:
		return "❔ " + link("no Hydra data", jobURL)
	}
}

func orDash(s string) string {
	if s == "" {
		return "—"
	}
	return s
}
