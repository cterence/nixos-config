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
  pkgs-vlc3-0-20 = final: _prev: {
    vlc3-0-20 = import inputs.nixpkgs-vlc3-0-20 {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  pkgs-gcloud-511 = final: _prev: {
    gcloud-511 = import inputs.nixpkgs-gcloud-511 {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
