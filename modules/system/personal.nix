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
      (retroarch.withCores (
        cores: with cores; [
          genesis-plus-gx
          snes9x
          pcsx-rearmed
          ppsspp
          dolphin
          fceumm
          gambatte
          melonds
          mupen64plus
          stella
          mgba
          desmume
        ]
      ))
      retroarch-joypad-autoconfig
      qbittorrent
      signal-desktop
      velero
      winetricks
      wineWow64Packages.stable
      emulationstation-de-wrapped
    ];
  };
}
