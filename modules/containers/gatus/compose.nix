{
  inputs,
  ...
}:
{
  flake.aspects.docker-compose-gatus.homeManager =
    { pkgs, config, ... }:
    let
      directory = "${config.home.homeDirectory}/gatus";
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
          ExecStartPre = "${pkgs.coreutils}/bin/install -Dm644 ${./config.yaml} ${directory}/config/config.yaml";
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
}
