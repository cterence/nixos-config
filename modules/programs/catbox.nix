{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    homelab-gitops = {
      url = "github:cterence/homelab-gitops";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.catbox = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          inputs.homelab-gitops.packages.${pkgs.stdenv.hostPlatform.system}.catbox
        ];
      };
  };
}
