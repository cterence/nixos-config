{
  flake.modules.nixos.homelab-settings =
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
          nfs-utils
          openiscsi
        ];
      };
      services = {
        pipewire.enable = false;
        openssh.enable = true;
        rpcbind.enable = true;
        openiscsi = {
          enable = true;
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
      networking = {
        firewall.enable = false;
      };
    };
}
