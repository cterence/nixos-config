{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  lib,
  glib,
  libsecret,
  libnotify,
  libudev0-shim,
  libX11,
  alsa-lib,
  libxkbcommon,
  expat,
  at-spi2-core,
  mesa,
  libXrandr,
  libXfixes,
  libXdamage,
  libXcomposite,
  cairo,
  gtk3,
  gtk2-x11,
  nspr,
  nss,
  asar,
  electron,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "forticlient";
  version = "7.4.0";

  src = fetchurl {
    url = "https://filestore.fortinet.com/forticlient/forticlient_vpn_7.4.0.1636_amd64.deb";
    sha256 = "sha256-GX3lETXAkyMwVBBxIPVd83ILAaaHnu8V7C/IT5IXtis=";
  };

  nativeBuildInputs = [
    dpkg
    asar
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glib
    libsecret
    libnotify
    libudev0-shim
    libX11
    alsa-lib
    libxkbcommon
    expat
    at-spi2-core
    mesa
    libXrandr
    libXfixes
    libXdamage
    libXcomposite
    cairo
    gtk3
    nspr
    gtk2-x11
    nss
  ];

  unpackPhase = "dpkg-deb --fsys-tarfile ${src} | tar -x --no-same-permissions --no-same-owner";

  preBuild = ''
    addAutoPatchelfSearchPath ${src}/opt/forticlient/gui/FortiClient-linux-x64
  '';

  installPhase =
    let
      libPath = lib.makeLibraryPath [
        libsecret
      ];
    in
    ''
      runHook preInstall

      mkdir $out
      mv -t $out env-vars lib opt usr
      asar e $out/opt/forticlient/gui/FortiClient-linux-x64/resources/app.asar asar-unpacked

      find asar-unpacked -name '*.node' -exec patchelf \
        --add-rpath "${libPath}" \
        {} \;

      substituteInPlace asar-unpacked/assets/js/main.js \
        --replace-fail "/opt/forticlient/forticlient-cli" "'$out/opt/forticlient/forticlient-cli'"

      # substituteInPlace asar-unpacked/src/app/api/server.js \
      #   --replace-fail "$.trim(fs.readFileSync(DYNAMIC_PORT[os.type()], 'utf-8'))" "30080"

      echo 30080 > $out/opt/forticlient/service_port

      substituteInPlace asar-unpacked/src/common/constants.js \
        --replace-fail "/var/run/forticlient/service_port" "$out/opt/forticlient/service_port"

      cp -r asar-unpacked $out/asar-unpacked
      asar p asar-unpacked $out/opt/forticlient/gui/FortiClient-linux-x64/resources/app.asar


      runHook postInstall
    '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/opt/forticlient/gui/FortiClient-linux-x64/resources/app.asar
  '';

  # meta = with lib; {
  #   description = "Digital audio workstation";
  #   longDescription = ''
  #     Bitwig Studio is a multi-platform music-creation system for
  #     production, performance and DJing, with a focus on flexible
  #     editing tools and a super-fast workflow.
  #   '';
  #   homepage = "https://www.bitwig.com/";
  #   # license = licenses.unfree;
  #   platforms = [ "x86_64-linux" ];
  #   maintainers = with maintainers; [
  #     bfortz
  #     michalrus
  #     mrVanDalo
  #   ];
  # };
}
