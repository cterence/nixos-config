pkgs: {
  aws-sso-util = pkgs.callPackage ./aws-sso-util.nix { };
  baywatch = pkgs.callPackage ./baywatch.nix { };
  guacamole = pkgs.callPackage ./guacamole.nix { };
  openfortivpn-webview = pkgs.callPackage ./openfortivpn-webview.nix { };
  playground = pkgs.callPackage ./playground.nix { };
}
