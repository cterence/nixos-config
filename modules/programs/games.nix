{ self, ... }:
{
  flake.modules.nixos.games =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        self.overlays.emulationstation-de
      ];
      environment.systemPackages = with pkgs; [
        heroic
        lutris
        mangohud
        protonup-rs
        winetricks
        wineWow64Packages.stable
        emulationstation-de
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
