{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      openiscsi
    ];
  };
  services = {
    openiscsi = {
      name = "iqn.2016-04.com.open-iscsi:918718e5103a";
      enable = true;
    };
  };
}
