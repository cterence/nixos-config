{ inputs, ... }:
{
  flake-file.inputs.k0s = {
    url = "github:johbo/k0s-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.k0s =
    { pkgs, ... }:
    {
      imports = [
        inputs.k0s.nixosModules.default
      ];

      nixpkgs.overlays = [
        inputs.k0s.overlays.default
      ];
      environment = {
        systemPackages = [
          inputs.k0s.packages.${pkgs.stdenv.hostPlatform.system}.k0s
        ];
      };
    };
}
