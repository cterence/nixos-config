{
  flake.aspects.settings-oracle.nixos =
    { pkgs, lib, ... }:
    {
      boot = {
        initrd.availableKernelModules = [
          "virtio_pci"
          "virtio_scsi"
          "usbhid"
          "nvme"
        ];
        kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
          "net.ipv4.ip_unprivileged_port_start" = 80;
        };
      };

      systemd = {
        network.enable = false;
        services = {
          tailscale-udp-optimizations = {
            description = "Tailscale UDP throughput optimizations";

            # Ensure this runs after the network is up
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };

            script = ''
              # Find the primary network interface
              NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")

              echo "Applying UDP offload optimizations to $NETDEV..."
              ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
            '';
          };
        };
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.PermitRootLogin = "yes";
      };

      networking = {
        useDHCP = true;
        dhcpcd.enable = true;
        useNetworkd = false;
        firewall.allowedTCPPorts = [
          80
          443
        ];
      };

      virtualisation.docker = {
        enable = lib.mkForce false;
      };
      security.sudo.wheelNeedsPassword = false;
    };
}
