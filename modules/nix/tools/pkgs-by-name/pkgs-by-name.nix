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
  #
  # pkgs-by-name-for-flake-parts exposes every package under `packages` for
  # every system with no `meta.platforms` filtering, which makes
  # `nix flake check` trip on the platform assert (e.g. linear-linux on
  # darwin). Restrict each system's `packages` output (and the `local`
  # overlay below) to packages the current system can actually build.
  perSystem =
    {
      config,
      lib,
      pkgs,
      inputs',
      ...
    }:
    {
      pkgsDirectory = inputs.packages;

      _module.args.pkgs = lib.mkForce (
        import inputs.nixpkgs {
          system = inputs'.nixpkgs.legacyPackages.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        }
      );

      packages = lib.mkForce (
        lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform) config.legacyPackages
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
