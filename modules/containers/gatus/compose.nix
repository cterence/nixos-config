{
  inputs,
  ...
}:
{
  flake.aspects.docker-compose-gatus = {
    nixos =
      { config, ... }:
      {
        sops.secrets = {
          homelab-client-cert = {
            sopsFile = "${inputs.secrets}/homelab-client-cert.json";
            format = "binary";
            path = "/etc/ssl/private/homelab-client-cert.p12";
            mode = "0440";
            group = config.users.groups.keys.name;
          };
          homelab-client-cert-password = {
            sopsFile = "${inputs.secrets}/homelab-client-cert-password.yaml";
            mode = "0440";
            group = config.users.groups.keys.name;
          };
        };
      };

    homeManager =
      { pkgs, config, ... }:
      let
        directory = "${config.home.homeDirectory}/gatus";
        cert = "/etc/ssl/private/homelab-client-cert.p12";
        certPass = "/run/secrets/homelab-client-cert-password";
        extractCert = "${pkgs.openssl}/bin/openssl pkcs12 -in ${cert} -passin file:${certPass}";
      in
      {
        home.file."${directory}/compose.yaml".source = ./compose.yaml;

        sops.secrets = {
          telegram-token.sopsFile = "${inputs.secrets}/gatus.yaml";
          telegram-chat-id.sopsFile = "${inputs.secrets}/gatus.yaml";
        };

        sops.templates."gatus-env".content = ''
          TELEGRAM_TOKEN=${config.sops.placeholder.telegram-token}
          TELEGRAM_CHAT_ID=${config.sops.placeholder.telegram-chat-id}
        '';

        systemd.user.services.docker-compose-gatus = {
          Unit = {
            Description = "Docker Compose Service for Gatus";
            After = [ "docker.service" ];
          };

          Install = {
            WantedBy = [ "default.target" ];
          };

          Service = {
            Type = "simple";
            WorkingDirectory = directory;
            # copy, not symlink: the container can't follow nix store links
            ExecStartPre = [
              "${pkgs.coreutils}/bin/install -Dm644 ${./config.yaml} ${directory}/config/config.yaml"
              "${extractCert} -clcerts -nokeys -out ${directory}/client.pem"
              "${extractCert} -nocerts -nodes -out ${directory}/client.key"
              "${pkgs.coreutils}/bin/chmod 600 ${directory}/client.key"
            ];
            ExecStart = "${pkgs.docker}/bin/docker compose up";
            ExecStop = "${pkgs.docker}/bin/docker compose down";
            Restart = "always";
            Environment = [
              "DOCKER_HOST=unix://%t/docker.sock"
              "DOCKER_SOCKET_PATH=%t/docker.sock"
            ];
            EnvironmentFile = config.sops.templates."gatus-env".path;
          };
        };
      };
  };
}
