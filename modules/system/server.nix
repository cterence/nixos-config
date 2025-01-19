{ pkgs, config, ... }:

{
  # Needed for Longhorn
  environment = {
    systemPackages = with pkgs; [
      nfs-utils
      openiscsi
    ];
  };
  services = {
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
      tailscaled.serviceConfig = {
        RestartSec = "15s";
        RuntimeMaxSec = "4h";
      };
    };
  };
}
