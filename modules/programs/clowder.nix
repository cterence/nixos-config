{ inputs, ... }: {
  flake-file.inputs = {
    clowder = {
      url = "github:cterence/clowder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.clowder = {
    homeManager = { pkgs, ... }: {
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
