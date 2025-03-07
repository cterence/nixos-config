pkgs: {
  baywatch = pkgs.callPackage ./baywatch.nix { };
  gowebly = pkgs.callPackage ./gowebly.nix { };
  guacamole = pkgs.callPackage ./guacamole.nix { };
  playground = pkgs.callPackage ./playground.nix { };
}
