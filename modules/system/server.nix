{ pkgs, config, ... }:

{
  # Needed for Longhorn
  environment = {
    systemPackages = with pkgs; [
      openiscsi
    ];
  };
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:" + config.networking.hostName;
  };
  # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1740179416
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
}
