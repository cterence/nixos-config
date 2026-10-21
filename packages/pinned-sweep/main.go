// Command pinned-sweep sweeps multiverse pins (modules/pins.nix) against
// Hydra build status for nixpkgs/unstable: reports which pins are still
// needed, which can be dropped, and which failing closure packages need a
// new pin.
package main

import (
	"fmt"
	"os"
)

const version = "0.1.0"

const usage = `pinned-sweep — sweep multiverse pins against Hydra build status

Usage:
  pinned-sweep check [flags]        report pin + closure build status
  pinned-sweep apply [flags]        drop green pins, pin red closure packages
  pinned-sweep pin [flags]          pin packages whose derivations failed a
                                    real build (drv extracted from a CI log)
  pinned-sweep version

Check flags:
  --json                  print the verdict as JSON (stable schema) on stdout
  --flake <path>          flake to read pins from (default ".")
  --closure <host=attr>   also dry-run a host closure and Hydra-check the
                          packages it would build; repeatable; exit 1 on red
  --build-unknown         fallback: nix-build pins Hydra has no data for,
                          from nixos-unstable, for the native system only

Apply flags:
  --verdict <file>        merge a check verdict JSON; repeatable; runs an
                          inline check when omitted
  --pr                    commit to pinned-sweep/sweep, push and open/update
                          an automerge PR (needs GH_TOKEN); without it the
                          working tree is edited in place
  --preview               show what would change, write nothing
  --flake <path>          flake to read pins from (default ".")

Pin flags:
  --from-log <file>       CI build log to extract failing drvs from,
                          repeatable
  --system <system>       platform the failed build ran on (required)
  --pr                    commit to pinned-sweep/sweep, push and open/update
                          an automerge PR (needs GH_TOKEN)
  --preview               show what would change, write nothing
  --flake <path>          flake to read pins from (default ".")

Exit codes:
  0  success (including "nothing to do")
  1  runtime failure, or a --closure check found a red package
  2  invalid usage

Examples:
  pinned-sweep check
  pinned-sweep check --json > verdict.json
  pinned-sweep check --closure macbook=darwinConfigurations.macbook.system
  pinned-sweep apply --preview
  pinned-sweep apply --pr --verdict verdict.json`

func main() {
	os.Exit(run(os.Args[1:]))
}

func run(args []string) int {
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, usage)
		return 2
	}
	switch args[0] {
	case "check":
		return cmdCheck(args[1:])
	case "apply":
		return cmdApply(args[1:])
	case "pin":
		return cmdPin(args[1:])
	case "version", "--version":
		fmt.Println("pinned-sweep", version)
		return 0
	case "help", "-h", "--help":
		fmt.Println(usage)
		return 0
	default:
		fmt.Fprintf(os.Stderr, "pinned-sweep: unknown command %q\nRun: pinned-sweep --help\n", args[0])
		return 2
	}
}
