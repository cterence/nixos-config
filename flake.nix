{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    k0s = {
      url = "github:cterence/k0s-nix/feat/k0s-1-31";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-work-config = {
      url = "github:cterence/nixos-work-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      kolide-launcher,
      nix-index-database,
      sops-nix,
      k0s,
      nixos-work-config,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      packages = import ./pkgs nixpkgs.legacyPackages.x86_64-linux;
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        stronghold = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/stronghold/configuration.nix
            home-manager.nixosModules.default
            nix-index-database.nixosModules.nix-index
          ];
        };
        t14s = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/t14s/configuration.nix
            home-manager.nixosModules.default
            nix-index-database.nixosModules.nix-index
            nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
            sops-nix.nixosModules.sops
          ];
        };
        homelab = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs k0s;
          };
          modules = [
            ./hosts/homelab/configuration.nix
            home-manager.nixosModules.default
            k0s.nixosModules.default
            nix-index-database.nixosModules.nix-index
            sops-nix.nixosModules.sops
          ];
        };
        homelab2 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs k0s;
          };
          modules = [
            ./hosts/homelab2/configuration.nix
            home-manager.nixosModules.default
            k0s.nixosModules.default
            nix-index-database.nixosModules.nix-index
            sops-nix.nixosModules.sops
          ];
        };
        framework = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/framework/configuration.nix
            home-manager.nixosModules.default
            kolide-launcher.nixosModules.kolide-launcher
            nixos-hardware.nixosModules.framework-13-7040-amd
            nix-index-database.nixosModules.nix-index
            nixos-work-config.nixosModules.system
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
