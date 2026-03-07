{ inputs, ... }:
{
  flake.modules.nixos.framework13 = {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "kvm-amd" ];
      extraModulePackages = [ ];
      initrd = {
        kernelModules = [ ];
        luks.devices."luks-b0ae69e3-ce45-4a01-9221-6ec2153e86df".device =
          "/dev/disk/by-uuid/b0ae69e3-ce45-4a01-9221-6ec2153e86df";
        luks.devices."luks-def6a8fd-8e33-45fd-84d4-79c43e2cddb0".device =
          "/dev/disk/by-uuid/def6a8fd-8e33-45fd-84d4-79c43e2cddb0";
      };
    };

    fileSystems."/" = {
      device = "/dev/mapper/luks-def6a8fd-8e33-45fd-84d4-79c43e2cddb0";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/8D09-5F41";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/mapper/luks-b0ae69e3-ce45-4a01-9221-6ec2153e86df"; }
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
  };
}
