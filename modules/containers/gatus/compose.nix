{
  flake.aspects.docker-compose-gatus.homeManager =
    { pkgs, config, ... }:
    let
      directory = "${config.home.homeDirectory}/gatus";
    in
    {
      home.file."${directory}/compose.yaml".source = ./compose.yaml;

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
          ExecStart = "${pkgs.docker}/bin/docker compose up";
          ExecStop = "${pkgs.docker}/bin/docker compose down";
          Restart = "always";
          Environment = [
            "DOCKER_HOST=unix://%t/docker.sock"
            "DOCKER_SOCKET_PATH=%t/docker.sock"
          ];
        };
      };
    };
}
