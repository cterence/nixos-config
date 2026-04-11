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
        version = "3.4.1";
        src = inputs.emulationstation-de;
        # Remove incompatible patches defined in oldPkgs.emulationstation-de
        patches = [ ];
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
