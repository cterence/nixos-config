{ inputs, ... }:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
  };

  flake.modules.nixos.disko = {
    imports = [ inputs.disko.nixosModules.disko ];
  };
}
