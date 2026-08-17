{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  asar,
  darwin,
}:

let
  sources = {
    version = "9.20.0";
    aarch64-darwin = {
      url = "https://electron-dl.todoist.net/mac/Todoist-darwin-9.20.0-arm64-latest.dmg";
      hash = "sha256-YAkabIQs3ereM0ja3LGIfTkcJyJBTWINtr4lUlr8V3w=";
    };
    x86_64-darwin = {
      url = "https://electron-dl.todoist.net/mac/Todoist-darwin-9.20.0-x64-latest.dmg";
      hash = "sha256-TBRVAyHuFzOoy2zLZRvebTNJGXeVlZhMFvAjEHKH21c=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "todoist-electron";
  inherit (sources) version;

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = [
    _7zz
    asar
    darwin.sigtool
  ];

  sourceRoot = ".";

  # undmg does not support APFS; 7zz does.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld $src
    runHook postUnpack
  '';

  # Get rid of the autoupdater (mirrors the nixpkgs linux package)
  postPatch = ''
    appdir="Todoist.app/Contents/Resources"
    ${lib.getExe asar} extract "$appdir/app.asar" app
    sed -i.bak 's/async isUpdateAvailable.*/async isUpdateAvailable(updateInfo) { return false;/g' app/node_modules/electron-updater/out/AppUpdater.js
    rm app/node_modules/electron-updater/out/AppUpdater.js.bak
    ${lib.getExe asar} pack app "$appdir/app.asar"
    rm -rf app
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a Todoist.app $out/Applications/

    # The asar patch above breaks the bundle seal; re-sign the main executable
    # ad-hoc so macOS LaunchServices accepts it (mirrors the lmstudio package).
    codesign --force --sign - "$out/Applications/Todoist.app/Contents/MacOS/Todoist"
    runHook postInstall
  '';

  # Let the bundle (with shipped Scripts/helpers) stay untouched by stdenv fixups.
  dontFixup = true;

  meta = {
    description = "To-Do List App & Task Manager";
    homepage = "https://www.todoist.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cterence ];
    mainProgram = "todoist-electron";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
