{ inputs, withSystem, ... }:
{
  flake-file.inputs = {
    packages = {
      flake = false;
      url = "path:./packages";
    };

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  };

  imports = [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  perSystem = {
    pkgsDirectory = inputs.packages;
  };

  flake = {
    overlays.default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
    };
  };

  flake.modules.generic.pkgs-by-name = {
    nixpkgs.overlays = [
      inputs.self.overlays.default
    ];
  };
}
