# nixos-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS configuration of all my computers / servers using flakes.

Currently managing configuration for 3 computers and 2 servers.

Structure is heavily inspired by [Vimjoyer's](https://www.youtube.com/@vimjoyer) videos.

I'm still new to the nix ecosystem, so you might see some slop, but it works for me.

**Highlights**

- Secret encryption with [sops-nix](https://github.com/Mic92/sops-nix)
- Homelab servers configuration with [k0s Kubernetes](https://k0sproject.io/)
- Daily [automated flake updates](https://github.com/cterence/nixos-config/actions) with change reporting
- Epic [Gnome](./modules/user/gnome.nix) and [Thunderbird](./modules/user/thunderbird.nix) configurations
- Some [custom packages](./pkgs/)

**Reinstall tips**

:warning: Do not run `nixos-rebuild switch --flake [...]` before doing this, else `nix-daemon` will crash and you'll have to reboot to a previous generation!

- On the new host
  - Generate a new `age` key:
    ```shell
    nix-shell -p age
    age-keygen -o ~/.config/sops/age/keys.txt
    ```
  - Update the `modules/system/.sops.yaml` file with the new key directly in GitHub
- On an existing host
  - Run `sops updatekeys modules/system/secrets.yaml`
  - Commit & push
- On the new host
  - Pull the repo

You may now use the flake to rebuild.