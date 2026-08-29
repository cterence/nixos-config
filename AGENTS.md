# AGENTS.md

Guidance for AI agents working in this repo.

## What this is

Personal nix flake managing NixOS and nix-darwin hosts. Uses
**flake-parts** + **`vic/import-tree`** + **`vic/flake-aspects`**.

- `flake.nix` is **auto-generated — do NOT edit it.** Regenerate with
  `nix run .#write-flake`. Inputs and outputs are declared in-module via
  `flake-file.inputs` / `flake-file.outputs`, then aggregated by
  `flake-file`.
- `import-tree ./modules` auto-discovers every `.nix` file under `modules/`.
  Files are read from the **git tree**, not the working directory — so new
  modules MUST be `git add`ed or they will be invisible to the flake and
  produce "undefined variable" errors.
- Each module registers aspects via `flake.aspects.<name>.<class>` (where
  class is `homeManager`, `darwin`, `nixos`, or `generic`).
- Aspects are activated by listing them in a host's `includes` list:
  `modules/hosts/<host>/configuration.nix` →
  `flake.aspects.<host>.includes = with aspects; [ ... ];`

## Key directories

- `modules/hosts/` — per-host config (macbook, homelab2, homelab3,
  stronghold, free-oracle-arm-1, free-oracle-amd-1, free-oracle-amd-2)
- `modules/programs/` — program aspects (shell, git, docker, cli-tools, etc.)
- `modules/system/` — system settings and type profiles (base/, types/, settings/)
- `modules/users/` — per-user aspects (terence)
- `modules/services/` — service aspects (audio, bluetooth, tailscale, niks3,
  comin, printing, fingerprint, kopia-sync)
- `modules/containers/` — container configs (gatus docker-compose stack)
- `modules/overlays/` — nixpkgs overlays (discord pin, emulationstation pin)
- `modules/nix/` — flake-parts bootstrap, home-manager, lib helpers, sops,
  disko, nixos-anywhere, pkgs-by-name
- `modules/devshells/` — devShells + pre-commit hooks
- `packages/` — custom packages (pkgs-by-name-for-flake-parts)
- `dotfiles/` — raw non-nix config via `path:./dotfiles` flake input
- `secrets/` — sops-encrypted secret files (flake=false input)
- `patches/` — local patches applied in devshells (flake=false input)

## Architecture: flake-aspects

Aspects compose per-host config without host-specific conditionals:

- `flake.aspects.<name>.homeManager` — home-manager module
- `flake.aspects.<name>.darwin` — nix-darwin module
- `flake.aspects.<name>.nixos` — NixOS module
- `flake.aspects.<name>.generic` — shared across both darwin and nixos

A host (e.g. macbook) lists which aspects to include:
```nix
flake.aspects.macbook = { aspects, ... }: {
  includes = with aspects; [
    system-macos
    terence-desktop
    ssh
  ];
};
```

System types in `modules/system/types/` are themselves aspects that compose
other aspects. The hierarchy:

```
system-minimal → system-default → system-cli → {system-desktop, system-server, system-oracle}
                                              system-macos (standalone)
system-laptop (leaf, nixos only)
system-personal (composable extra)
```

## Hosts

| Host                | System           | Type       | Key aspects                                                         | Notes                                           |
|---------------------|------------------|------------|---------------------------------------------------------------------|-------------------------------------------------|
| `macbook`           | `aarch64-darwin` | `mkDarwin` | system-macos, system-desktop, system-personal, terence-desktop, ssh | `stateVersion = 7`                              |
| `homelab2`          | `x86_64-linux`   | `mkNixos`  | system-server, k0s (controller), comin, terence-server              | k0s leader at 192.168.1.54; openbao unseal keys |
| `homelab3`          | `x86_64-linux`   | `mkNixos`  | system-server, k0s (worker, disabled), development, terence-server  | NFS server; k0s-token via sops                  |
| `stronghold`        | `x86_64-linux`   | `mkNixos`  | system-desktop, system-personal, comin, terence-desktop             | AMD GPU (RX 6600), kopia-sync                   |
| `free-oracle-arm-1` | `aarch64-linux`  | `mkNixos`  | system-oracle, terence-server                                       | disko; WireGuard; Oracle Cloud                  |
| `free-oracle-amd-1` | `x86_64-linux`   | `mkNixos`  | system-oracle, terence-server                                       | disko; zramSwap; docker-compose-gatus           |
| `free-oracle-amd-2` | `x86_64-linux`   | `mkNixos`  | system-oracle, terence-server                                       | disko; zramSwap                                 |

## Adding a new module

1. Create the `.nix` file under `modules/`.
2. `git add` the file immediately (import-tree needs it in the tree).
3. Add the aspect name to the relevant host's `includes` list.

## Applying changes

Agents should NOT run the rebuild/switch themselves. After making changes,
tell the user to apply them so they can review and control the deployment:

- macOS (this machine): `nhs` (alias for `nh darwin switch ~/nix-darwin`)
- NixOS remote hosts: `ssh <host>` then `nixos-rebuild switch --flake .#<host>`
  or the host's `nh` equivalent.
- Oracle hosts (fresh install): `nix develop .#install` (patched
  nixos-anywhere), then `nixos-anywhere --flake .#<host> ... opc@<ip>`.
- Pull + rebuild: `nhup` (alias: `git pull --rebase --autostash && nhs`).

## Conventions

- Format with **nixfmt** (enforced by pre-commit: nixfmt + statix + deadnix +
  gitleaks + trufflehog + flake-checker). Run `nix develop` to install hooks.
- Use `${pkgs.<package>}/bin/<binary>` for script/program references — never
  bare command names that rely on PATH resolution.
- Don't hardcode usernames; use `self.lib.username` (= `"terence"`).
- Don't hardcode `User` in ssh config blocks — some hosts don't have a
  `terence` account (e.g. `ssh root@homelab3`).
- Verify changes evaluate before claiming done:
  `nix eval --raw .#darwinConfigurations.macbook` (or the relevant host).
  Note: NixOS hosts can't be cross-built from macOS — verify on the host.
- `stateVersion`: darwin hosts `= 7`; NixOS hosts `= "25.11"`; HM `= "25.11"`.

## Secrets (sops-nix)

- age-only encryption (no GPG/PGP). Keys in `.sops.yaml` (10 hosts).
- Secret files in `secrets/` (flake=false input, `path:./secrets`).
- age key locations: NixOS `/home/terence/.config/sops/age/keys.txt`,
  darwin `/Users/terence/.config/sops/age/keys.txt`.
- sops-nix wired into nixos/darwin/homeManager via `aspects.secrets`
  (`modules/nix/tools/secrets/sops.nix`).
- sops templates preferred over `cat ${secret.path}` at shell startup.
- Edit secrets with `sops secrets/<file>.yaml`.

## nixpkgs pins

When a package breaks on unstable, pin a known-good nixpkgs commit as a new
input next to the module that uses it:

| Input                      | Reason                                    | File                                    |
|----------------------------|-------------------------------------------|-----------------------------------------|
| `nixpkgs-discord-darwin`   | macOS Discord corruption (nixpkgs#544338) | `modules/overlays/discord.nix`          |
| `nixpkgs-emulationstation` | emulationstation-de build break           | `modules/overlays/emulationstation.nix` |

Find the last good revision: `nix shell nixpkgs#hydra-check -c hydra-check --channel unstable <pkg>`.

## Custom packages

Auto-discovered by `pkgs-by-name-for-flake-parts` from `packages/`:

| Package            | Platforms             | Description                              |
|--------------------|-----------------------|------------------------------------------|
| `todoist-electron` | aarch64/x86_64-darwin | Todoist 9.20.0, patched + re-signed DMG  |
| `iterm2-ai-plugin` | darwin                | iTermAI 1.1 app                          |
| `linear-linux`     | linux                 | Linear desktop app (dpkg + autoPatchelf) |

Exposed as `.#<name>` and via `pkgs.local.<name>` overlay.

## Dotfiles

Raw non-nix files in `dotfiles/` (flake=false, `path:./dotfiles`), sourced
declaratively via `inputs.dotfiles` in modules. Used for: `.p10k.zsh`,
ghostty config, `.XCompose`, k9s plugins, skopeo policy, vibe config.

## Maintaining this file

Keep this file up to date as the repo evolves. When you learn a new gotcha,
convention, or workflow detail during a session, add it here so future agents
benefit. This is a living document.
