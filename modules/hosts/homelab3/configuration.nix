{ inputs, self, ... }:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "homelab3";
  flake.modules.nixos.homelab3 =
    { config, ... }:
    {
      imports = with self.modules.nixos; [
        system-server
        systemd-boot
        k0s
        terence-server
      ];
      networking.hostName = "homelab3";

      sops.secrets = {
        "k0s-token" = {
          path = "/etc/k0s/k0stoken";
          mode = "0440";
          sopsFile = "${inputs.secrets}/k0s-token.yaml";
          group = config.users.groups.keys.name;
        };
      };

      services.k0s = {
        enable = false;
        role = "worker";
        spec = {
          api = {
            address = "192.168.1.54";
            sans = [
              "192.168.1.54"
            ];
          };
        };
      };

      system.stateVersion = "25.11";
    };
}
