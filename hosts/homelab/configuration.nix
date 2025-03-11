# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  k0s,
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
    hostName = "homelab"; # Define your hostname.
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

  services.k0s = {
    enable = true;
    role = "controller+worker";
    isLeader = true;
    spec = {
      api = {
        address = "192.168.1.31";
        sans = [
          "192.168.1.31"
          "172.18.0.1"
          "172.19.0.1"
          "172.22.0.1"
          "172.20.0.1"
          "172.17.0.1"
          "100.75.180.13"
          "fe80::987c:cf64:426a:4e6"
          "fe80::42:35ff:fec5:670a"
          "fe80::42:41ff:fec9:8efd"
          "fe80::42:dff:fe9d:22fb"
          "fe80::42:6aff:feb5:37f5"
          "fe80::d07e:2ff:fe4b:db1b"
          "fe80::8c3a:a5ff:fe93:d39c"
          "fe80::209f:deff:fec4:213c"
          "fe80::5027:ccff:fed2:517"
          "fe80::9480:bfff:fe15:ebeb"
          "fe80::6c4e:18ff:fead:f736"
          "fe80::bc34:f7ff:fed4:aad9"
          "fe80::4865:fff:fe0d:b5c0"
          "fe80::e859:5fff:fed3:5f25"
          "fe80::6ceb:9cff:fe6a:b3b3"
          "fe80::f850:30ff:fe9f:de90"
          "fe80::8ce7:4aff:fe9d:1088"
          "fe80::f0eb:8bff:fea2:1905"
          "fe80::48d8:5ff:fe29:d7f4"
          "fe80::e4ed:d9ff:fed2:50d3"
          "fd7a:115c:a1e0::a501:b40d"
          "fe80::ceef:d0ff:eae1:f67d"
        ];
      };
      network.kuberouter.metricsPort = 8081;
      storage.etcd.peerAddress = "192.168.1.31";
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
