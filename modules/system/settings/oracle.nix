{
  flake.modules.nixos.settings-oracle = {
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
      };
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "yes";
    };

    systemd.network.enable = false;
    networking = {
      useDHCP = true;
      dhcpcd.enable = true;
      useNetworkd = false;
    };
    security.sudo.wheelNeedsPassword = false;
  };
}
