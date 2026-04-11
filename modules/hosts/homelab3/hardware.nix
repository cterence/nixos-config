{
  flake.modules.nixos.homelab3 = {
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
        device = "/dev/disk/by-uuid/c8afe7e6-3dcc-4b98-baac-1698ddeea155";
        fsType = "ext4";
      };
      "/mnt/mx500-02" = {
        device = "/dev/disk/by-uuid/c1b5d2dc-c0c6-4dab-ba17-3ac7425e2a34";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
        ];
      };
      "/export/mx500-homelab3" = {
        device = "/mnt/mx500-02/k8s-data";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/mnt/mx500-02" ];
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
        device = "/dev/disk/by-uuid/23D5-7E17";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/mx500-02/k8s-data 0777 root root -"
    ];

    swapDevices = [
      { device = "/dev/disk/by-uuid/04352eda-e976-48d1-822b-450cc6638d7a"; }
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
    };
  };
}
