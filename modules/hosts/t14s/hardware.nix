{ inputs, ... }:
{
  flake.modules.nixos.t14s = {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
    ];

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ "kvm-amd" ];
      extraModulePackages = [ ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/b7abd0b2-b567-46a0-91f7-63f7e63f789b";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/F0B2-CF53";
        fsType = "vfat";
      };
    };

    swapDevices = [ ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
    };
  };
}
