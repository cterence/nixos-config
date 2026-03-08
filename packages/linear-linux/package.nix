{
  stdenv,
  fetchurl,
  dpkg,
  lib,
  autoPatchelfHook,
  gtk3,
  webkitgtk_4_1,
  glib,
  cairo,
  gdk-pixbuf,
  libsoup_3,
  wrapGAppsHook4,
  glib-networking,
  makeWrapper,
  hicolor-icon-theme,
}:
stdenv.mkDerivation rec {
  version = "0.2.3";
  pname = "linear-linux";

  src = fetchurl {
    url = "https://github.com/zacharyftw/${pname}/releases/download/v${version}/Linear_${version}_amd64.deb";
    hash = "sha256-Hp3fT1DAvemT3jlQEJqDF0iXwbQm0+WutM///O5j4YI=";
  };
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook4
    makeWrapper
  ];

  buildInputs = [
    hicolor-icon-theme
    gtk3
    webkitgtk_4_1
    glib
    glib-networking
    cairo
    gdk-pixbuf
    libsoup_3
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
    # Ensure the binary is executable
    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  postInstall = ''
    # Find the high-res icon path
    ICON_PATH=$out/share/icons/hicolor/1024x1024/apps/linear-linux.png

    substituteInPlace $out/share/applications/Linear.desktop \
      --replace-fail "Exec=linear-linux" "Exec=$out/bin/linear-linux" \
      --replace-fail "Icon=linear-linux" "Icon=$ICON_PATH" \
      --replace-fail "Categories=" "Categories=Office;Development;ProjectManagement;"
  '';

  meta = {
    description = "Linear";
    homepage = "https://linear.app";
    downloadPage = "https://github.com/zacharyftw/${pname}/releases";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cterence ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
