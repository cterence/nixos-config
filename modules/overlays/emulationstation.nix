{ inputs, ... }:
{
  flake-file.inputs = {
    # Commit preceding https://github.com/NixOS/nixpkgs/commit/608422bd4ba434d02278602bc74c46d10bfde2ba
    nixpkgs-emulationstation.url = "github:nixos/nixpkgs/845134719941b3a2087842eae23e521d67e35ad5";

    emulationstation-de = {
      flake = false;
      url = "gitlab:es-de/emulationstation-de";
    };
  };

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
