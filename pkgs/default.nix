pkgs: {
  baywatch = pkgs.callPackage ./baywatch.nix { };
  guacamole = pkgs.callPackage ./guacamole.nix { };
  playground = pkgs.callPackage ./playground.nix { };
}
