{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      openiscsi
    ];
  };
  services = {
    openiscsi.enable = true;
  };
}
