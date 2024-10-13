# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{

  environment = {
    systemPackages = with pkgs; [
      calibre
      mangohud
      nextcloud-client
      picard
      qbittorrent
      signal-desktop
      velero
      winetricks
      wineWowPackages.stable
    ];
  };
}
