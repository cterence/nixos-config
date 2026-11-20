{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation rec {
  pname = "vibe-desktop";
  version = "1.3.0";

  src = fetchurl {
    url = "https://storage.googleapis.com/mistralai-ci-desktop-app/vibe-${version}.dmg";
    hash = "sha256-G/JlBCFZiVmFk0lPw/kNNwxcU5+HOCTkHzdzc8vHzTY=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a Vibe.app $out/Applications/
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
