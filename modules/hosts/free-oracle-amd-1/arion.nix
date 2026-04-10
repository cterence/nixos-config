{ inputs, ... }:
{
  flake.modules.nixos.free-oracle-amd-1 = {
    imports = [ inputs.arion.nixosModules.arion ];

    virtualisation.arion = {
      backend = "docker";
      projects.gatus-stack.settings = {
        project.name = "gatus-stack";

        networks.gatus_default = { };

        docker-compose.volumes = {
          gatus_data = { };
        };

        services = {
          gatus = {
            out.service.logging = {
              driver = "journald";
            };

            service = {
              image = "twinproduction/gatus:latest";
              volumes = [
                "/home/terence/gatus/client.key:/client.key:rw"
                "/home/terence/gatus/client.pem:/client.pem:rw"
                "/home/terence/gatus/config:/config:rw"
                "gatus_data:/data:rw"
              ];
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.gatus.entrypoints" = "websecure";
                "traefik.http.routers.gatus.rule" = "Host(`status.terence.cloud`)";
                "traefik.http.routers.gatus.tls.certresolver" = "myresolver";
              };
              networks.gatus_default.aliases = [ "gatus" ];
              restart = "always";
            };
          };

          traefik = {
            out.service.logging = {
              driver = "journald";
            };

            service = {
              image = "traefik:v3.6";
              volumes = [
                "/home/terence/gatus/letsencrypt:/letsencrypt:rw"
                "/var/run/docker.sock:/var/run/docker.sock:ro"
              ];
              ports = [
                "80:80/tcp"
                "443:443/tcp"
                "8080:8080/tcp"
              ];
              command = [
                "--providers.docker=true"
                "--providers.docker.exposedbydefault=false"
                "--entryPoints.web.address=:80"
                "--entryPoints.websecure.address=:443"
                "--certificatesresolvers.myresolver.acme.httpchallenge=true"
                "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
                "--certificatesresolvers.myresolver.acme.email=terence.chateigne@posteo.net"
                "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
                "--entrypoints.web.http.redirections.entryPoint.to=websecure"
                "--entrypoints.web.http.redirections.entryPoint.scheme=https"
                "--entrypoints.web.http.redirections.entrypoint.permanent=true"
              ];
              networks.gatus_default.aliases = [ "traefik" ];
              restart = "always";
            };
          };
        };
      };
    };
  };
}
