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
  pkgs-emulationstation = final: _prev: {
    emulationstation-de-fixed = final.symlinkJoin {
      name = "emulationstation-de-fixed";
      paths = [
        (import inputs.nixpkgs-emulationstation {
          inherit (final) system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "freeimage-3.18.0-unstable-2024-04-18" ];
        }).emulationstation-de
      ];

      nativeBuildInputs = [ final.makeWrapper ];

      postBuild = ''
        wrapProgram $out/bin/es-de \
          --set SDL_VIDEODRIVER x11
      '';
    };
  };
}
