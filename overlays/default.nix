# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # modifications = final: prev: {
  # example = prev.example.overrideAttrs (oldAttrs: rec {
  # ...
  # });
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  pkgs-emulationstation = final: _: {
    emulationstation-de-fixed =
      let
        oldPkgs = import inputs.nixpkgs-emulationstation {
          inherit (final.stdenv.hostPlatform) system;
          config.permittedInsecurePackages = [ "freeimage-3.18.0-unstable-2024-04-18" ];
        };
      in
      oldPkgs.emulationstation-de.overrideAttrs (_: {
        version = "3.4.0";

        src = final.fetchFromGitLab {
          owner = "es-de";
          repo = "emulationstation-de";
          rev = "v3.4.0";
          hash = "sha256-poegMKtPtUbdUbAwVj6O+rh7bxou+Wc+IDS3TBHh2LU=";
        };
      });

    emulationstation-de-wrapped = final.symlinkJoin {
      name = "emulationstation-de-wrapped";
      paths = [ final.emulationstation-de-fixed ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/es-de \
          --set SDL_VIDEODRIVER x11
      '';
    };
  };
}
