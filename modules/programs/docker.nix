{ inputs, ... }: {
  # FIXME: https://github.com/NixOS/nixpkgs/issues/540426
  flake-file.inputs = {
    nixpkgs-lima.url = "github:nixos/nixpkgs/9778ed56742b4080a2cbe033c0ba2ad1732a6ce3";
  };

  flake.aspects.docker = {
    nixos = {
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
    homeManager = { lib, pkgs, ... }: {
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        with pkgs;
        [
          docker
          docker-compose
          docker-credential-helpers
        ]
      );
      services = {
        colima = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = true;
          package = inputs.nixpkgs-lima.legacyPackages.aarch64-darwin.colima;
        };
      };
    };
  };
}
