{ inputs, ... }:
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.comin =
    { config, ... }:
    {
      imports = [
        inputs.comin.nixosModules.comin
      ];

      services.comin = {
        enable = true;
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
