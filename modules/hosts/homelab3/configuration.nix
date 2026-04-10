{ inputs, self, ... }:
let
  hostname = "homelab3";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;
  flake.modules.nixos.homelab3 =
    { config, ... }:
    {
      imports = with self.modules.nixos; [
        system-server
        systemd-boot
        k0s
        terence-server
      ];
      networking.hostName = hostname;

      sops.secrets = {
        k0s-token = {
          path = "/etc/k0s/k0stoken";
          mode = "0440";
          sopsFile = "${inputs.secrets}/k0s-token.yaml";
          group = config.users.groups.keys.name;
        };
      };

      services = {
        k0s = {
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
        nfs.server = {
          enable = true;
          exports = ''
            /export                 192.168.1.54/32(rw,fsid=0,no_subtree_check,all_squash,anonuid=1000,anongid=100)
            /export/mx500-homelab3  192.168.1.54/32(rw,nohide,no_subtree_check,all_squash,anonuid=1000,anongid=100)
          '';
        };
      };

      system.stateVersion = "25.11";
    };
}
