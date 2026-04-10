{ self, ... }:
{
  # How to be able to nixos-anywhere kexec without oomkill:
  # ssh opc@_ip_
  # sudo -i
  # systemctl stop pmcd pmlogger pmproxy pmie
  # pkill -9 pmda
  # systemctl stop oracle-cloud-agent
  # systemctl stop oracle-cloud-agent-updater
  # pkill -u ocarun
  # systemctl stop firewalld
  # systemctl stop tuned
  # sync; echo 3 > /proc/sys/vm/drop_caches
  # echo 1 > /proc/sys/vm/compact_memory

  # Then run:
  # nixos-anywhere --flake .#free-amd-instance-1 --no-disko-deps opc@_ip_

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "free-amd-instance-1";
  flake.modules.nixos.free-amd-instance-1 = {
    imports = with self.modules.nixos; [
      system-minimal
      disko
      home-manager
      qol
    ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = false;

      # Critical for Oracle ARM to find /dev/sda
      initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
        "nvme" # Added just in case of host migration
      ];
    };

    networking.hostName = "free-amd-instance-1";
    system.stateVersion = "25.11";

    # User Configuration
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
      ];
    };

    # MANDATORY: Add key to root so nixos-anywhere can finish the install
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
    ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "yes";
    };

    systemd.network.enable = false;
    networking = {
      useDHCP = true;
      dhcpcd.enable = true;
      useNetworkd = false;
    };
    security.sudo.wheelNeedsPassword = false;
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 150; # 1GB RAM -> 1.5GB zram
      priority = 10;
    };
  };
}
