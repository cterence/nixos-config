{
  flake.aspects.stronghold.nixos = {
    boot = {
      kernelParams = [ "acpi_backlight=video" ];
      kernelModules = [
        "kvm-amd"
        "i2c-dev"
      ];
      extraModulePackages = [ ];
      initrd = {
        availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = [ ];
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/83263226-8908-4963-8344-20f96234990c";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/7F1A-55C3";
        fsType = "vfat";
      };
      "/mnt/elements" = {
        device = "/dev/disk/by-uuid/fd25a6c7-4e9d-4838-9375-ca13460b05b5";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
          "x-systemd.automount"
          "noauto"
        ];
      };
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/9fd4feb3-15f8-4d6b-a9e8-70a383f1f362"; } ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
    };
  };
}
