{
  inputs,
  self,
  ...
}:
let
  home-manager-config =
    { pkgs, ... }:
    {
      home-manager = {
        verbose = true;
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        backupCommand = "rm";
        overwriteBackup = true;
      };

      nixpkgs.overlays = [
        (_: _: {
          local = self.packages.${pkgs.stdenv.hostPlatform.system};
        })
      ];
    };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
