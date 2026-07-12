{ inputs, self, ... }:
{
  flake-file.inputs = {
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.niks3 = {
    generic =
      { pkgs, ... }:
      {
        environment.systemPackages = [ inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3 ];

        sops.secrets = {
          niks3-signing-key = {
            key = "signing-key";
            sopsFile = "${inputs.secrets}/niks3.yaml";
          };
          niks3-api-token = {
            key = "api-token";
            sopsFile = "${inputs.secrets}/niks3.yaml";
          };
        };
      };

    nixos = { config, ... }: {
      imports = [
        inputs.niks3.nixosModules.niks3-auto-upload
        self.modules.generic.niks3
      ];

      services.niks3-auto-upload = {
        enable = true;
        serverUrl = "https://niks3.terence.cloud";
        authTokenFile = config.sops.secrets.niks3-api-token.path;
      };
    };

    darwin = {
      imports = [
        self.modules.generic.niks3
      ];
    };

    homeManager =
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
  };
}
