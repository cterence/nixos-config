# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  programs = {
    adb.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      avidemux
      audacity
      calibre
      mangohud
      mp3gain
      nextcloud-client
      nicotine-plus
      opencloud-desktop
      picard
      qbittorrent
      signal-desktop
      velero
      winetricks
      wineWowPackages.stable
    ];
  };
}
