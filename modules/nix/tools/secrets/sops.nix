{ inputs, ... }:
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

  flake.modules.nixos.secrets = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.homeManager.secrets = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
