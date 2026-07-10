{ self, ... }:
{
  flake.aspects.games = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        self.overlays.emulationstation-de
      ];

      imports = [
        self.modules.generic.games
      ];

      environment.systemPackages = with pkgs; [
        heroic
        mangohud
        protonup-rs
        winetricks
        emulationstation-de
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
        wineWow64Packages.stable
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
  };
}
