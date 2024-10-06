{
  buildGoModule,
}:

buildGoModule rec {
  pname = "guacamole";
  version = "0.2.0";

  src = builtins.fetchGit {
    url = "git@github.com:padok-team/guacamole.git";
    ref = "refs/tags/v${version}";
    rev = "3598050d0134aaab6c496c6bdf65c7f140165388";
  };

  vendorHash = "sha256-8zbbd9yv25+Pda3sLtSr/tGbS475sqjLGcoOmTTdNzg=";

  ldflags = [
    "-s"
    "-X github.com/padok-team/guacamole/internal/version.Version=v${version}"
  ];
}
