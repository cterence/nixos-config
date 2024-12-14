# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  programs = {
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
      calibre
      kopia
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
