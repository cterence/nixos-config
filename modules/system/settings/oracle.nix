{
  flake.modules.nixos.settings-oracle = {
    boot = {
      initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
        "nvme"
      ];
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
