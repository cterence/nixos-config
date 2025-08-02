# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  k0s,
  config,
  pkgs,
  lib,
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
    outputs.overlays.pkgs-util-linux-with-patches
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit (config) sops fileSystems;
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

  systemd.settings.Manager = {
    DefaultLimitNOFILE = "16384";
  };

  sops.secrets = {
    "b2-velero-backup-tch-key-id" = {
      mode = "0440";
      group = config.users.groups.keys.name;
      owner = config.users.users.terence.name;
      sopsFile = ./secrets.yaml;
    };
    "b2-velero-backup-tch-key" = {
      mode = "0440";
      group = config.users.groups.keys.name;
      owner = config.users.users.terence.name;
      sopsFile = ./secrets.yaml;
    };
    "kopia-password" = {
      mode = "0440";
      group = config.users.groups.keys.name;
      owner = config.users.users.terence.name;
      sopsFile = ./secrets.yaml;
    };
  };

  systemd.services.k0scontroller.path = lib.mkForce (
    with pkgs;
    [
      coreutils
      findutils
      gnugrep
      gnused
      kmod
      systemd
      util-linux-with-patches.util-linux.withPatches
    ]
  );

  services.k0s = {
    enable = true;
    role = "controller+worker";
    isLeader = true;
    spec = {
      api = {
        address = "192.168.1.54";
        sans = [
          "192.168.1.54"
        ];
      };
      network.kuberouter.metricsPort = 8081;
      storage.etcd.peerAddress = "192.168.1.54";
    };
  };

  virtualisation.containerd = {
    enable = true;
  };

  environment = {
    systemPackages = [
      k0s.packages.x86_64-linux.k0s
    ];
  };
}
