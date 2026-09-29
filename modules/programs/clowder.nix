{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    clowder = {
      url = "github:cterence/clowder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.clowder = {
    # The daemon runs as a systemd user unit (the HM module below); without
    # linger the user manager — and the daemon with it — dies with the last
    # ssh session, so headless hosts look permanently offline.
    nixos = {
      users.users.${self.lib.username}.linger = true;
    };

    homeManager =
      { pkgs, ... }:
      {
        imports = [
          inputs.clowder.homeManagerModules.default
        ];

        services.clowder.enable = true;

        home.packages = [
          inputs.clowder.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
  };
}
