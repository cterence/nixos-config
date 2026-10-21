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
      qbittorrent = {
        version = "5.2.2";
        tracker = "https://github.com/NixOS/nixpkgs/issues/576182";
        reason = "5.2.4 fails on darwin against qtbase 6.12";
      };
    };
    nixos = {
      audacity = {
        version = "3.7.9";
        tracker = "https://github.com/NixOS/nixpkgs/issues/572942";
        reason = "4.0.0 fails against qtdeclarative 6.12";
      };
      calibre = {
        version = "9.14.0";
        tracker = "https://github.com/NixOS/nixpkgs/pull/576063";
        reason = "9.15+ fails via pyopenjtalk-plus + Cython 3.3.0";
      };
    };
  };
in
{
  flake.pins = pins;

  # Sidecar overlay: applies every pin to the matching platform's package set,
  # so modules use `pkgs.<pkg>` without knowing pins exist. Applied once in
  # system-minimal's generic class; home-manager follows via useGlobalPkgs.
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
