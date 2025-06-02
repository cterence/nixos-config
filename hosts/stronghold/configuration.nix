# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, outputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/system/common.nix
    ../../modules/system/gnome.nix
    ../../modules/system/desktop.nix
    ../../modules/system/personal.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "terence" = import ./home.nix;
    };
  };

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.pkgs-vlc3-0-20
    outputs.overlays.pkgs-util-linux-2-40
  ];

  networking = {
    hostName = "stronghold"; # Define your hostname.
  };

  systemd.timers."tboi-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1d";
      Unit = "tboi-backup.service";
    };
  };

  systemd.services."tboi-backup" = {
    script = ''
      # Take a backup of the save directory for The Binding of Isaac: Rebirth
      TIME=$(date +"%Y-%m-%d_%H-%M-%S")
      cp -r ~/.local/share/Steam/userdata/182269349/250900/remote ~/Nextcloud/Archives/TBOI/backup_$TIME
      echo "Backup taken at $TIME" >> ~/Nextcloud/Archives/TBOI/backup.log

      # Only keep the last 5 backups if there are more than 5
      cd ~/Nextcloud/Archives/TBOI
      # Count the number of backups
      COUNT=$(ls -1 | grep backup_ | wc -l)
      # If there are more than 5 backups, delete the oldest ones
      if [ $COUNT -gt 5 ]; then
          # Delete the oldest backups
          ls -1 | head -n $(($COUNT - 5)) | xargs rm -r
          echo "Deleted $(($COUNT - 5)) old backups" >> ~/Nextcloud/Archives/TBOI/backup.log
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "terence";
    };
  };

  system = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = "23.11"; # Did you read the comment?
  };
}
