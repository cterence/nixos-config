# Single source of truth for multiverse pins. Machine-managed by
# `packages/pinned-sweep` (`pinned-sweep apply`) — it regenerates this file.
# Each pin: version to pin, upstream nixpkgs tracker, and why.
{ inputs, ... }:
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

  # Sidecar overlay: applies every pin to the matching platform's package
  # set, so modules use `pkgs.<pkg>` without knowing pins exist. Wired in
  # system-minimal's darwin/nixos classes; home-manager follows via
  # useGlobalPkgs.
  flake.overlays.multiverse-pins =
    final: _prev:
    let
      overlay = inputs.multiverse.lib.pinOverlay {
        pins = builtins.mapAttrs (_: pin: pin.version) (
          if final.stdenv.hostPlatform.isDarwin then pins.darwin else pins.nixos
        );
      };
    in
    overlay final _prev;
}
