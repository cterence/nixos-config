{
  inputs,
  ...
}:
{
  # Needed to avoid recursion / module redefinition errors
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  systems = [
    "x86_64-linux"
  ];

  perSystem =
    { system, config, ... }:
    {
      # Make custom packages available in pkgs with local prefix
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (_: _: {
            local = config.packages;
          })
        ];
      };
      pkgsDirectory = inputs.packages;
    };
}
