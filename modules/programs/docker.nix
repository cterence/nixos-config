{
  flake.aspects.docker = {
    nixos = {
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
    homeManager = { lib, pkgs, ... }: {
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        with pkgs;
        [
          docker
          docker-buildx
          docker-compose
          docker-credential-helpers
        ]
      );
      services = {
        colima = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = true;
        };
      };
    };
  };
}
