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
  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      flake = false;
      url = "path:./dotfiles";
    };
  };

  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake.aspects.home-manager = {
    nixos = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        home-manager-config
      ];
    };

    darwin = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        home-manager-config
      ];
    };
  };
}
