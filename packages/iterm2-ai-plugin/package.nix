{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "iterm2-ai-plugin";
  version = "1.1";

  src = pkgs.fetchurl {
    url = "https://github.com/gnachman/iterm2-website/raw/refs/heads/master/downloads/ai-plugin/iTermAI-${version}.zip";
    sha256 = "0hlzz4k88y10qds41wlf7lvpbifxqjbizrjmjcg1ppq9b584fmbf";
  };

  nativeBuildInputs = [ pkgs.unzip ];
  buildInputs = [ ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/Applications
    mkdir -p tmp-extract
    unzip $src -d tmp-extract
    mv "tmp-extract/iTermAI.app" $out/Applications/
    chmod -R u+rwX "$out/Applications/iTermAI.app"
  '';
}
