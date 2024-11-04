# This file defines overlays
_: {
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
  # pkgs-c31898ad = final: _prev: {
  #   c31898ad = import inputs.nixpkgs-c31898ad {
  #     inherit (final) system;
  #     config.allowUnfree = true;
  #   };
  # };
}
