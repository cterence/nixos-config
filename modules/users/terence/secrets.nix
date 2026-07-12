{
  inputs,
  self,
  ...
}:
let
  username = "terence";
in
{
  flake.aspects."${username}-secrets" = {
    generic =
      { config, ... }:
      {
        sops = {
          secrets = {
            nixos-access-tokens = {
              sopsFile = "${inputs.secrets}/settings.yaml";
            };
            nix-daemon-environment = {
              sopsFile = "${inputs.secrets}/settings.yaml";
            };
          };
        };

        nix.extraOptions = ''
          !include ${config.sops.secrets.nixos-access-tokens.path}
        '';

      };

    nixos = { config, ... }: {
      imports = [ self.modules.generic."${username}-secrets" ];

      sops = {
        age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
        secrets = {
          nixos-access-tokens = {
            mode = "0440";
            group = config.users.groups.keys.name;
          };
          nix-daemon-environment = {
            mode = "0440";
            group = config.users.groups.keys.name;
          };
        };
      };

      systemd = {
        services = {
          nix-daemon.serviceConfig.EnvironmentFile = config.sops.secrets.nix-daemon-environment.path;
        };
      };
    };

    darwin = {
      imports = [ self.modules.generic."${username}-secrets" ];

      sops = {
        age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
      };
    };

    homeManager =
      { config, ... }:
      {
        sops = {
          age.keyFile = config.home.homeDirectory + "/.config/sops/age/keys.txt";
          secrets = {
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

        home.sessionVariables = {
          SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };
  };
}
