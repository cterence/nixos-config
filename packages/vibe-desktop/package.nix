{
  lib,
  stdenv,
  fetchurl,
  _7zz,
}:

stdenv.mkDerivation rec {
  pname = "vibe-desktop";
  version = "1.3.0";

  src = fetchurl {
    url = "https://storage.googleapis.com/mistralai-ci-desktop-app/vibe-${version}.dmg";
    hash = "sha256-G/JlBCFZiVmFk0lPw/kNNwxcU5+HOCTkHzdzc8vHzTY=";
  };

  nativeBuildInputs = [ _7zz ];

  sourceRoot = ".";

  # undmg does not support APFS; 7zz does.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a "Install Vibe by Mistral/Vibe.app" $out/Applications/

    # 7zz drops xattrs (com.apple.macl etc.), which breaks the bundle seal and
    # makes Gatekeeper report the app as damaged; re-sign ad-hoc. sigtool's
    # codesign has no --deep, so use the system one.
    /usr/bin/codesign --force --sign - --deep "$out/Applications/Vibe.app"
    runHook postInstall
  '';

  # Leave the signed bundle untouched by stdenv fixups.
  dontFixup = true;

  meta = {
    description = "Mistral Vibe desktop app";
    homepage = "https://mistral.ai";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
