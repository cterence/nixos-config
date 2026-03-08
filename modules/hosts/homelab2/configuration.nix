{ inputs, self, ... }:
{
  flake.modules.nixos.homelab2 = {
    imports =
      with self.modules.nixos;
      [
        common-settings
        homelab-settings
        common-services
        cli-tools
        docker
        home-manager
        homelab-client-cert
        k0s
        systemd-boot
        terence
        tailscale
      ]
      ++ [
        inputs.sops-nix.nixosModules.sops
        inputs.k0s.nixosModules.default
      ];
    networking.hostName = "homelab2";

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
