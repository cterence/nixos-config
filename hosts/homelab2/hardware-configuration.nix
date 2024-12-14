# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
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
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-amd"
      "nfsd"
      "cdc_acm"
    ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "nfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/71306661-b21b-4dc6-8981-a5972dfb7904";
      fsType = "ext4";
    };
    "/mnt/870evo" = {
      device = "/dev/disk/by-uuid/ac2a68b8-7f0e-4db9-939f-f9fb0ca1d66e";
      fsType = "ext4";
      options = [
        "users"
        "nofail"
      ];
    };
    "/mnt/elements" = {
      device = "/dev/disk/by-uuid/59c35643-ee1a-42ef-ab04-18965d910d61";
      fsType = "ext4";
      options = [
        "users"
        "nofail"
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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
