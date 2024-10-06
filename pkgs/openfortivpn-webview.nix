{
  buildNpmPackage,
  electron,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "openfortivpn-webview";
  version = "1.2.3-electron";

  src = fetchFromGitHub {
    owner = "gm-vm";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jGDCFdqRfnYwUgVs3KO1pDr52JgkYVRHi2KvABaZFl4=";
  };

  sourceRoot = "${src.name}/openfortivpn-webview-electron";

  npmDepsHash = "sha256-NKGu9jZMc+gd4BV1PnF4ukCNkjdUpZIJlYJ7ZzO+5WI=";
  dontNpmBuild = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/openfortivpn-webview \
        --add-flags $out/lib/node_modules/openfortivpn-webview/index.js
  '';

  meta = {
    description = "Application to perform the SAML single sign-on and easily retrieve the SVPNCOOKIE needed by openfortivpn";
    homepage = "https://github.com/gm-vm/openfortivpn-webview";
    downloadPage = "https://github.com/gm-vm/openfortivpn-webview/releases";
    changelog = "https://github.com/gm-vm/openfortivpn-webview/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "openfortivpn-webview";
    maintainers = with lib.maintainers; [
      cterence
    ];
    platforms = lib.platforms.linux;
  };
}
