{ self, ... }:
let
  hostname = "homelab2";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;
  flake.modules.nixos.homelab2 = {
    imports = with self.modules.nixos; [
      system-server
      systemd-boot
      k0s
      terence-server
    ];
    networking.hostName = hostname;

    services.k0s = {
      enable = true;
      role = "controller+worker";
      controller.isLeader = true;
      spec = {
        api = {
          address = "192.168.1.54";
          sans = [
            "192.168.1.54"
          ];
        };
        network.kuberouter.metricsPort = 8081;
        storage.etcd.peerAddress = "192.168.1.54";
      };
    };

    system.stateVersion = "25.11";
  };
}
