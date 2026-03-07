{
  flake.modules.nixos.games =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        heroic
        lutris
        mangohud
        protonup-rs
        winetricks
        wineWow64Packages.stable
      ];

      programs = {
        gamemode.enable = true;
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
    };
}
