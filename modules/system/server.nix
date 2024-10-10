{ pkgs, config, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      openiscsi
    ];
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:" + config.networking.hostName;
  };
}
