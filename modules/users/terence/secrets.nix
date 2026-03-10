{
  inputs,
  ...
}:
let
  username = "terence";
in
{
  flake.modules.nixos."${username}" =
    { config, ... }:
    {
      sops = {
        age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
        secrets = {
          "nixos-access-tokens" = {
            mode = "0440";
            sopsFile = "${inputs.secrets}/settings.yaml";
            group = config.users.groups.keys.name;
            owner = config.users.users.terence.name;
          };
          "nix-daemon-environment" = {
            mode = "0440";
            path = config.systemd.services.nix-daemon.serviceConfig.EnvironmentFile;
            sopsFile = "${inputs.secrets}/settings.yaml";
            group = config.users.groups.keys.name;
            owner = config.users.users.terence.name;
          };
        };
      };
    };

  flake.modules.homeManager."${username}" =
    { config, ... }:
    {
      sops = {
        age.keyFile = config.home.homeDirectory + "/.config/sops/age/keys.txt";
        secrets = {
          "gh-cli-token" = {
            mode = "0440";
            sopsFile = "${inputs.secrets}/gh-cli-token.yaml";
          };
        };
      };

      programs.zsh.initContent = ''
        export GH_TOKEN="$(cat ${config.sops.secrets.gh-cli-token.path})"
      '';
    };
}
