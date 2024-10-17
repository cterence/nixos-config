# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  k0s,
  config,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/system/common.nix
    ../../modules/system/server.nix
  ];

  nixpkgs.overlays = [
    outputs.overlays.additions
    k0s.overlays.default
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
    hostName = "homelab2"; # Define your hostname.
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
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

  systemd.extraConfig = "DefaultLimitNOFILE=16384";

  sops = {
    secrets = {
      "k0s-token" = {
        path = "/etc/k0s/k0stoken";
        mode = "0440";
        sopsFile = ./secrets.yaml;
        group = config.users.groups.keys.name;
      };
    };
  };

  services.k0s = {
    enable = true;
    role = "worker";
    spec.api = {
      address = "192.168.1.31";
      sans = [
        "192.168.1.31"
      ];
    };
  };

  virtualisation.containerd = {
    enable = true;
  };
}
