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
      # avidemux # failing to build and not often used: https://github.com/NixOS/nixpkgs/pull/376912
      bun
      calibre
      gowebly
      mangohud
      mp3gain
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
