{ inputs, ... }:
{
  flake.modules.nixos.niks3 =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.niks3.nixosModules.niks3-auto-upload
      ];

      environment.systemPackages = [ inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3 ];

      nix.settings = {
        substituters = [
          "https://niks3.terence.cloud"
        ];
        trusted-public-keys = [
          "niks3.terence.cloud-1:YBjuY7HeSjKk5wmvw8N+vq/us2GxQPCHRn871lL7XL4="
        ];
      };

      services.niks3-auto-upload = {
        enable = true;
        serverUrl = "https://niks3.terence.cloud";
        authTokenFile = config.sops.secrets.niks3-api-token.path;
      };

      sops.secrets = {
        niks3-signing-key = {
          key = "signing-key";
          sopsFile = "${inputs.secrets}/niks3.yaml";
          mode = "0440";
          group = config.users.groups.keys.name;
        };
        niks3-api-token = {
          key = "api-token";
          sopsFile = "${inputs.secrets}/niks3.yaml";
        };
      };
    };

  flake.modules.homeManager.niks3 =
    { config, ... }:
    {
      sops.secrets = {
        niks3-api-token = {
          key = "api-token";
          sopsFile = "${inputs.secrets}/niks3.yaml";
        };
      };

      programs.zsh.initContent = ''
        export NIKS3_SERVER_URL=https://niks3.terence.cloud
        export NIKS3_API_TOKEN=$(cat ${config.sops.secrets.niks3-api-token.path})
        export NIKS3_AUTH_TOKEN_FILE=${config.sops.secrets.niks3-api-token.path}
      '';
    };

}
