{
  flake.aspects.stronghold.nixos = { pkgs, lib, ... }: {
    boot = {
      kernelParams = [
        "acpi_backlight=video"
        # Disable GFXOFF: clears PP_GFXOFF_MASK (bit 15) from the default
        # ppfeaturemask 0xfff7bfff → 0xfff73fff. Workaround for SMU lockups
        # on Navi 23 / RX 6600 (kernel 7.1.x) where "Failed to disable
        # gfxoff!" precedes a full GPU hang.
        # "amdgpu.ppfeaturemask=0xfff73fff"
      ];
      # Test: pin to 6.12 LTS to isolate amdgpu regressions in 7.1.x on
      # Navi 23. Remove this line to go back to linuxPackages_latest.
      kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;
      kernelModules = [
        "kvm-amd"
        "i2c-dev"
        "amdgpu"
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
        kernelModules = [ "amdgpu" ];
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
      i2c.enable = true;
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
      graphics = {
        enable = true;
        enable32Bit = true; # Useful for Steam/Wine
      };
    };
  };
}
