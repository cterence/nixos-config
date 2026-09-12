{
  lib,
  stdenv,
  fetchurl,
  _7zz,
}:

let
  version = "1.26.8";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/artraweditor/ART/releases/download/${version}/ART-${version}_macOS-14.8_arm64.dmg";
      hash = "sha256-g/gbFtr65mTPf3aV6GCw7rxvr0UDgpT/t3CQ7l8f/cU=";
      dir = "ART-${version}_macOS-14.8_arm64";
    };
    x86_64-darwin = {
      url = "https://github.com/artraweditor/ART/releases/download/${version}/ART-${version}_macOS-15.7_x64.dmg";
      hash = "sha256-A2WUZWjNxHLwQI5nUbdLidsZbiUuueoc38ka/X5PpZc=";
      dir = "ART-${version}_macOS-15.7_x64";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "art";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = [ _7zz ];

  # undmg does not support APFS; 7zz does.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld $src
    runHook postUnpack
  '';

  # Let the bundle (with shipped Frameworks and symlinked resources) stay
  # untouched by stdenv fixups.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a "${source.dir}/ART.app" $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "A powerful, cross-platform raw image processing program";
    homepage = "https://github.com/artraweditor/ART";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cterence ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
