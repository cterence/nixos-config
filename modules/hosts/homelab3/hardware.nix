{
  flake.aspects.homelab3.nixos = { pkgs, ... }: {
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
          "noatime"
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
          "noatime"
          "x-systemd.automount"
          "noauto"
        ];
      };
      "/mnt/exos-10tb-1" = {
        device = "/dev/disk/by-uuid/80dc1dc1-f805-4cd7-bad4-344431ec79fd";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
          "noatime"
        ];
      };
      "/mnt/storage-pool" = {
        # mergerfs: append more branches colon-separated, e.g. "/mnt/exos-10tb-1:/mnt/<newdisk>"
        device = "/mnt/exos-10tb-1";
        fsType = "fuse.mergerfs";
        options = [
          "defaults"
          "allow_other"
          "dropcacheonclose=true"
          "category.create=pfrd"
          "minfreespace=100G"
          "moveonenospc=mspmfs"
          "ignorepponrename=true"
          "never-forget-nodes=true"
          "inodecalc=path-hash"
          "lazy-umount-mountpoint=false"
          "fsname=storage-pool"
          "nofail"
        ];
        depends = [ "/mnt/exos-10tb-1" ];
      };
      "/export/storage-pool" = {
        device = "/mnt/storage-pool";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/mnt/storage-pool" ];
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
      "d /mnt/storage-pool/local-path-provisioner 0777 root root -"
    ];

    environment.systemPackages = [ pkgs.mergerfs ];

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
