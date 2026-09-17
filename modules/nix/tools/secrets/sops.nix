{ inputs, self, ... }:
{
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      flake = false;
      url = "path:./secrets";
    };
  };

  # sops-install-secrets is built with buildGo125Module, which nixpkgs turned into
  # a throw once Go 1.25 hit end-of-life. sops.package is evaluated against the
  # consumer's nixpkgs, so alias the removed builder to buildGoModule until
  # sops-nix ships a fix. https://github.com/Mic92/sops-nix/issues/983
  flake.aspects.secrets = {
    nixos = {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      nixpkgs.overlays = [
        self.overlays.sops-build-go
      ];
    };

    darwin = {
      imports = [
        inputs.sops-nix.darwinModules.sops
      ];
      nixpkgs.overlays = [
        self.overlays.sops-build-go
      ];
    };

    homeManager = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      nixpkgs.overlays = [
        self.overlays.sops-build-go
      ];
    };
  };
}
