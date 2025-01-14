pkgs: {
  baywatch = pkgs.callPackage ./baywatch.nix { };
  guacamole = pkgs.callPackage ./guacamole.nix { };
  har-to-k6 = pkgs.callPackage ./har-to-k6.nix { };
  playground = pkgs.callPackage ./playground.nix { };
}
