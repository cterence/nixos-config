{ inputs, ... }:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.disko.nixos = {
    imports = [ inputs.disko.nixosModules.disko ];
  };
}
