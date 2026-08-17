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

  # The packages exposed via `.#<name>` are built with the perSystem `pkgs`,
  # which flake-parts defaults to the raw nixpkgs input (no `allowUnfree`).
  # Several local packages (e.g. todoist-electron) have unfree licenses, so
  # reimport nixpkgs with `allowUnfree = true` to match the system/home-manager
  # configs and make `nix build .#<name>` work without env vars.
  perSystem = { lib, inputs', ... }: {
    pkgsDirectory = inputs.packages;

    _module.args.pkgs = lib.mkForce (
      import inputs.nixpkgs {
        system = inputs'.nixpkgs.legacyPackages.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }
    );
  };

  flake = {
    overlays.default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
    };
  };

  flake.aspects.pkgs-by-name.generic = {
    nixpkgs.overlays = [
      inputs.self.overlays.default
    ];
  };
}
