{
  flake.aspects.homelab2.nixos = {
    boot = {
      kernelParams = [ ];
      kernelModules = [
        "kvm-amd"
        "nfsd"
        "cdc_acm"
      ];
      extraModulePackages = [ ];
      initrd = {
        availableKernelModules = [
          "nvme"
          "xhci_pci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "dm_crypt"
        ];
        kernelModules = [ ];
      };
      supportedFilesystems = [ "nfs" ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/71306661-b21b-4dc6-8981-a5972dfb7904";
        fsType = "ext4";
      };
      "/mnt/mx500-01" = {
        device = "/dev/disk/by-uuid/b5d27e7f-3fb0-4f22-98bc-f0a3fe77a7d7";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
        ];
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
      "/boot" = {
        device = "/dev/disk/by-uuid/C8AD-CF95";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/8cba34a6-305c-46e0-9aeb-4754a17dd7e5"; }
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
    };
  };
}
