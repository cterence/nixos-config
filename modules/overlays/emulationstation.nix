{ inputs, ... }:
{
  flake.overlays.emulationstation-de = final: _: {
    emulationstation-de-fixed =
      let
        oldPkgs = import inputs.nixpkgs-emulationstation {
          inherit (final.stdenv.hostPlatform) system;
          config.permittedInsecurePackages = [ "freeimage-3.18.0-unstable-2024-04-18" ];
        };
      in
      oldPkgs.emulationstation-de.overrideAttrs (_: {
        version = "3.4.0";

        src = final.fetchFromGitLab {
          owner = "es-de";
          repo = "emulationstation-de";
          rev = "v3.4.0";
          hash = "sha256-poegMKtPtUbdUbAwVj6O+rh7bxou+Wc+IDS3TBHh2LU=";
        };
      });

    emulationstation-de = final.symlinkJoin {
      name = "emulationstation-de";
      paths = [ final.emulationstation-de-fixed ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/es-de \
          --set SDL_VIDEODRIVER x11
      '';
    };
  };
}
