{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # FIXME: https://www.reddit.com/r/VLC/comments/1dexl6y/some_opus_audio_tracks_to_videos_not_playing_in/
    nixpkgs-vlc3-0-20.url = "github:nixos/nixpkgs/62b3c73a4e0e9ddc92de1c165492fce00c5027c4";

    # FIXME: gcloud beta compute ssh yields an error
    # INVALID_ARGUMENT: This region is not supported by the OS Login Sign API at this time.
    nixpkgs-gcloud-511.url = "github:nixos/nixpkgs/7d1a1590911cb3a8a1d3a906f78235d63b910d62";

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
      url = "github:johbo/k0s-nix";
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
        import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        }
      );

      # Common modules used across configurations
      commonModules = [
        home-manager.nixosModules.default
        nix-index-database.nixosModules.nix-index
        sops-nix.nixosModules.sops
      ];

      # Common special arguments
      commonSpecialArgs = {
        inherit inputs outputs;
      };

      mkSystem =
        {
          hostName,
          extraModules ? [ ],
          extraArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = commonSpecialArgs // extraArgs;
          modules =
            [
              ./hosts/${hostName}/configuration.nix
            ]
            ++ commonModules
            ++ extraModules;
        };

      mkHomelabSystem =
        name:
        mkSystem {
          hostName = name;
          extraModules = [ k0s.nixosModules.default ];
          extraArgs = { inherit k0s; };
        };
    in
    {
      packages = forAllSystems (system: {
        inherit (pkgs.${system})
          baywatch
          gowebly
          guacamole
          playground
          ;
      });
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
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      nixosConfigurations = {
        stronghold = mkSystem {
          hostName = "stronghold";
        };
        t14s = mkSystem {
          hostName = "t14s";
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
          ];
        };
        homelab = mkHomelabSystem "homelab";
        homelab2 = mkHomelabSystem "homelab2";
        homelab3 = mkHomelabSystem "homelab3";
        framework = mkSystem {
          hostName = "framework";
          extraModules = [
            kolide-launcher.nixosModules.kolide-launcher
            nixos-hardware.nixosModules.framework-13-7040-amd
            nixos-work-config.nixosModules.system
          ];
          extraArgs = { inherit plasma-manager; };
        };
      };
    };
}
