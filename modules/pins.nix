# Single source of truth for multiverse pins. Machine-managed by
# `packages/pinned-sweep` (`pinned-sweep apply`) — it regenerates this file.
# Each pin: version to pin, upstream nixpkgs tracker, and why.
{ ... }:
let
  pins = {
    darwin = {
      picard = {
        version = "2.13.3";
        tracker = "https://github.com/NixOS/nixpkgs/issues/572435";
        reason = "3.0 fails to build on darwin";
      };
    };
    nixos = { };
  };
in
{
  flake.pins = pins;

  # Pins resolve through the multiverse overlay in
  # modules/system/types/base/system-minimal.nix (per class, darwin/nixos.)
}
