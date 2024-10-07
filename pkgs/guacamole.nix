{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "guacamole";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "padok-team";
    repo = "guacamole";
    rev = "refs/tags/v${version}";
    hash = "sha256-jLOSVpnRre3A/nn+H43SuefNDEz0nLv0chlfgRanQHE=";
  };

  vendorHash = "sha256-8zbbd9yv25+Pda3sLtSr/tGbS475sqjLGcoOmTTdNzg=";

  ldflags = [
    "-s"
    "-X github.com/padok-team/guacamole/internal/version.Version=v${version}"
  ];
}
