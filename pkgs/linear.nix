{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "0.2.1";
  pname = "linear-linux";

  src = fetchurl {
    url = "https://github.com/kleo-dev/${pname}/releases/download/v${version}/${pname}-${version}.AppImage";
    hash = "sha256-mvsoNWwji4Fme2C8fxwpRbNoAAJN0jan+cZ0tYjNghk=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/2048x2048/apps/${pname}.png \
      $out/share/icons/hicolor/2048x2048/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

  meta = {
    description = "Linear";
    homepage = "https://linear.app";
    downloadPage = "https://github.com/kleo-dev/${pname}/releases";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cterence ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
