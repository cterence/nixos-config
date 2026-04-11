{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Commit preceding https://github.com/NixOS/nixpkgs/commit/608422bd4ba434d02278602bc74c46d10bfde2ba
    nixpkgs-emulationstation.url = "github:nixos/nixpkgs/845134719941b3a2087842eae23e521d67e35ad5";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    k0s = {
      url = "github:johbo/k0s-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    packages = {
      flake = false;
      url = "path:./packages";
    };

    dotfiles = {
      flake = false;
      url = "path:./dotfiles";
    };

    secrets = {
      flake = false;
      url = "path:./secrets";
    };

    patches = {
      flake = false;
      url = "path:./patches";
    };

    emulationstation-de = {
      flake = false;
      url = "gitlab:es-de/emulationstation-de";
    };

    caveman-skills = {
      flake = false;
      url = "github:JuliusBrussee/caveman";
    };

    go-skills = {
      flake = false;
      url = "github:spf13/go-skills";
    };

    terraform-skills = {
      flake = false;
      url = "github:hashicorp/agent-skills";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
