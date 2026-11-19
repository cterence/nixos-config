# Single source of truth for multiverse pins. Machine-managed by
# `packages/pinned-sweep` (`pinned-sweep apply`) — it regenerates this file.
# Each pin: version to pin, upstream nixpkgs tracker, and why.
_:
let
  pins = {
    darwin = { };
    nixos = { };
  };
in
{
  flake.pins = pins;

  # Pins resolve through the multiverse overlay in
  # modules/system/types/base/system-minimal.nix (per class, darwin/nixos.)
}
