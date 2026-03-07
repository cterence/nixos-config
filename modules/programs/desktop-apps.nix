{
  flake.modules.homeManager.desktop-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        audacity
        calibre
        gpu-screen-recorder
        libreoffice-fresh
        nextcloud-client
        obsidian
        picard
        qbittorrent
        qemu
        signal-desktop
        supersonic
        todoist-electron
        vlc
      ];
    };
}
