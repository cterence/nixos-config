{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "dm_crypt"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
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
    "/boot" = {
      device = "/dev/disk/by-uuid/23D5-7E17";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/04352eda-e976-48d1-822b-450cc6638d7a"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
