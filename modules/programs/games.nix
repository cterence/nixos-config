{ self, ... }:
{
  flake.aspects.games.nixos =
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
            mesen
            mupen64plus
            stella
            mgba
            desmume
          ]
        ))
        winetricks
        wineWow64Packages.stable
        emulationstation-de
      ];

      programs = {
        gamemode.enable = true;
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = false;
          dedicatedServer.openFirewall = false;
        };
      };
    };
}
