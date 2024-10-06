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

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/479b8eaf-bbd2-4664-93e9-35a5c5048916";
    fsType = "ext4";
  };

  boot.initrd.luks.devices = {
    "luks-323ca694-6610-43ac-8301-12a6147b0b7d".device = "/dev/disk/by-uuid/323ca694-6610-43ac-8301-12a6147b0b7d";
    "luks-f9c699d2-ebfa-4767-9eb5-e852889a08df".device = "/dev/disk/by-uuid/f9c699d2-ebfa-4767-9eb5-e852889a08df";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A2CD-2965";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/dev/mapper/luks-f9c699d2-ebfa-4767-9eb5-e852889a08df";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
