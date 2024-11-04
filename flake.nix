{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # FIXME: while azure-cli fails to build
    # nixpkgs-c31898ad.url = "github:nixos/nixpkgs/c31898adf5a8ed202ce5bea9f347b1c6871f32d1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    baywatch = {
      url = "github:padok-team/baywatch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    k0s = {
      url = "github:cterence/k0s-nix";
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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      home-manager,
      k0s,
      kolide-launcher,
      nix-index-database,
      nixos-hardware,
      nixos-work-config,
      nixpkgs,
      plasma-manager,
      sops-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (
        system:
        nixpkgs.legacyPackages.${system} {
          overlays = [
            self.overlays.default
          ];
        }
      );
    in
    {
      packages = {
        inherit (pkgs)
          aws-sso-util
          baywatch
          google-chat-linux
          guacamole
          openfortivpn-webview
          playground
          ;
      };
      overlays = import ./overlays { inherit inputs; };
      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            flake-checker.enable = true;
            nil.enable = true;
            nixfmt-rfc-style.enable = true;
            statix.enable = true;
          };
        };
      });
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
      formatter = forAllSystems (system: {
        ${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      });
      nixosConfigurations = {
        stronghold = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/stronghold/configuration.nix
            home-manager.nixosModules.default
            nix-index-database.nixosModules.nix-index
            sops-nix.nixosModules.sops
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
            inherit inputs outputs plasma-manager;
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
