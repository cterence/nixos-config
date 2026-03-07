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
