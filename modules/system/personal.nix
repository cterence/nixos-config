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
      # avidemux # failing to build and not often used: https://github.com/NixOS/nixpkgs/pull/376912
      bun
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
