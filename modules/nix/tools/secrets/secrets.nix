{ inputs, ... }:
{
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
