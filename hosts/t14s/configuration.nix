# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  ...
}:

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

  nixpkgs.overlays = [
    inputs.nix-alien.overlays.default
    outputs.overlays.additions
    outputs.overlays.pkgs-emulationstation
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "terence" = import ./home.nix;
    };
  };

  networking = {
    hostName = "t14s"; # Define your hostname.
  };

  systemd = {
    services = {
      # For some reason, the brightness level is reset to 100% after resuming from suspend.
      # The previous value is still stored in /sys/class/backlight/amdgpu_bl1/brightness.
      # Applying a small modification to the value will reset the brightness level to the previous value.
      "reset-screen-brightness" = {
        script = ''
          echo "Resetting screen brightness"
          BR=$(cat /sys/class/backlight/amdgpu_bl1/brightness)
          echo $((BR + 1)) > /sys/class/backlight/amdgpu_bl1/brightness
          echo $((BR - 1)) > /sys/class/backlight/amdgpu_bl1/brightness
        '';
        after = [
          "suspend.target"
        ];
        wantedBy = [
          "suspend.target"
        ];
        serviceConfig = {
          User = "root";
        };
      };
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
