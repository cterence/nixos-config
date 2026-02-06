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
      android-tools
      audacity
      calibre
      heroic
      lutris
      mame
      mangohud
      mp3gain
      mupen64plus
      nextcloud-client
      nicotine-plus
      opencloud-desktop
      picard
      protonup-rs
      retroarch-free
      retroarch-joypad-autoconfig
      qbittorrent
      signal-desktop
      velero
      winetricks
      wineWowPackages.stable
      emulationstation-de-fixed
    ];
  };
}
