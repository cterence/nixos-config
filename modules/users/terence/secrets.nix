{
  inputs,
  ...
}:
let
  username = "terence";
in
{
  flake.aspects."${username}-secrets" = {
    nixos =
      { config, ... }:
      {
        sops = {
          age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
          secrets = {
            nixos-access-tokens = {
              mode = "0440";
              sopsFile = "${inputs.secrets}/settings.yaml";
              group = config.users.groups.keys.name;
            };
            nix-daemon-environment = {
              mode = "0440";
              sopsFile = "${inputs.secrets}/settings.yaml";
              group = config.users.groups.keys.name;
            };
          };
        };

        nix.extraOptions = ''
          !include ${config.sops.secrets.nixos-access-tokens.path}
        '';

        systemd = {
          services = {
            nix-daemon.serviceConfig.EnvironmentFile = config.sops.secrets.nix-daemon-environment.path;
          };
        };
      };

    homeManager =
      { config, ... }:
      {
        sops = {
          age.keyFile = config.home.homeDirectory + "/.config/sops/age/keys.txt";
          secrets = {
            gh-cli-token = {
              mode = "0440";
              sopsFile = "${inputs.secrets}/gh-cli-token.yaml";
            };
            oracle-config = {
              mode = "0440";
              key = "config";
              sopsFile = "${inputs.secrets}/oracle-cloud.yaml";
              path = config.home.homeDirectory + "/.oci/config";
            };
            oracle-private-key = {
              mode = "0440";
              key = "private_key";
              sopsFile = "${inputs.secrets}/oracle-cloud.yaml";
              path = config.home.homeDirectory + "/.oci/private_key.pem";
            };
          };
        };

        programs.zsh.initContent = ''
          export GH_TOKEN="$(cat ${config.sops.secrets.gh-cli-token.path})"
        '';
      };
  };
}
