{
  inputs,
  outputs,
  k0s,
  config,
  ...
}:

{
  imports = [
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
      inherit (config) sops fileSystems;
    };
    users = {
      "terence" = import ./home.nix;
    };
  };

  networking = {
    hostName = "homelab3";
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  system = {
    stateVersion = "24.05"; # Did you read the comment?
  };

  systemd.extraConfig = "DefaultLimitNOFILE=16384";

  # sops.secrets = {
  #   "k0s-token" = {
  #     path = "/etc/k0s/k0stoken";
  #     mode = "0440";
  #     sopsFile = ./secrets.yaml;
  #     group = config.users.groups.keys.name;
  #   };
  # };

  # services.k0s = {
  #   enable = true;
  #   role = "controller+worker";
  #   isLeader = true;
  #   spec = {
  #     api = {
  #       address = "192.168.1.54";
  #       sans = [
  #         "192.168.1.54"
  #       ];
  #     };
  #     network.kuberouter.metricsPort = 8081;
  #     storage.etcd.peerAddress = "192.168.1.54";
  #   };
  # };

  virtualisation.containerd = {
    enable = true;
  };

  environment = {
    systemPackages = [
      k0s.packages.x86_64-linux.k0s
    ];
  };
}
