{
  flake.aspects.settings-homelab.nixos =
    { pkgs, config, ... }:
    {
      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 524288;
        "fs.inotify.max_user_instances" = 1024;
      };

      systemd.settings.Manager = {
        DefaultLimitNOFILE = "16384";
      };

      virtualisation.containerd = {
        enable = true;
      };

      # Needed for Longhorn
      environment = {
        systemPackages = with pkgs; [
          mergerfs
          mergerfs-tools
          nfs-utils
          smartmontools
        ];
      };
      services = {
        openssh.enable = true;
        rpcbind.enable = true;
        openiscsi = {
          enable = false;
          name = "iqn.2016-04.com.open-iscsi:" + config.networking.hostName;
        };
      };
      # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1740179416
      systemd = {
        tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];
        services = {
          systemd-timesyncd.serviceConfig.RuntimeMaxSec = "1h";
          tailscaled.serviceConfig.RuntimeMaxSec = "4h";
        };
      };
      networking.firewall.allowedTCPPorts = [
        80
        443
        2049
        179 # kube-router BGP (pod CIDR routing between nodes)
        6443 # k0s kube-apiserver (worker → controller)
        8132 # k0s Konnectivity reverse tunnel (worker → controller)
        9443 # k0s controller API (controller ↔ controller)
        10250 # kubelet API (controller → worker)
      ];
    };
}
