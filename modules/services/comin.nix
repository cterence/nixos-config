{ inputs, ... }:
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.comin.nixos =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.comin.nixosModules.comin
      ];

      environment.systemPackages = [ inputs.comin.packages.${pkgs.stdenv.hostPlatform.system}.comin ];

      services.comin = {
        enable = true;
        desktop.enable = true;
        remotes = [
          {
            name = "origin";
            url = "https://github.com/cterence/nixos-config.git";
            branches.main.name = "main";
          }
          {
            name = "local";
            url = config.users.users.terence.home + "/nixos";
            branches.main.name = "main";
            poller.period = 10;
          }
        ];
      };
    };
}
