# nixos-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS configuration of all my computers / servers using flakes.

Currently managing configuration for 3 computers and 2 servers.

Structure is heavily inspired by [Vimjoyer's](https://www.youtube.com/@vimjoyer) videos.

I'm still new to the nix ecosystem, so you might see some slop, but it works for me.

**Highlights:**

- Secret encryption with [sops-nix](https://github.com/Mic92/sops-nix)
- Homelab servers configuration with [k0s Kubernetes](https://k0sproject.io/)
- Daily [automated flake updates](https://github.com/cterence/nixos-config/actions) with change reporting
- Epic [Gnome](./modules/user/gnome.nix) and [Thunderbird](./modules/user/thunderbird.nix) configurations
- Some [custom packages](./pkgs/)
