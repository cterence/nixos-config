{ inputs, ... }:
{
  flake-file.inputs.k0s = {
    url = "github:johbo/k0s-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.k0s.nixos =
    { pkgs, ... }:
    {
      # Patch upstream k0s-nix for attrTag strictness in newer nixpkgs (johbo/k0s-nix#105).
      # Source patched via inputs.nixpkgs to avoid module-arg recursion in imports.
      imports = [
        (import "${
          inputs.nixpkgs.legacyPackages.x86_64-linux.applyPatches {
            name = "k0s-nix-patched";
            src = inputs.k0s;
            patches = [ "${inputs.patches}/k0s-nix-attrtag-calico.patch" ];
          }
        }/nixos/k0s.nix")
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
