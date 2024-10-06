{
  buildGoModule,
}:

buildGoModule rec {
  pname = "baywatch";
  version = "0.2.2";

  src = builtins.fetchGit {
    url = "git@github.com:padok-team/baywatch.git";
    ref = "refs/tags/v${version}";
    rev = "f34e1c94535d1d5a50c00f4f666d0a917da16558";
  };

  vendorHash = "sha256-WOdaq8EhcDs9PTTclAhmji9+TtyxklYXLaSJnHrSyo4=";

  ldflags = [
    "-s"
    "-X github.com/padok-team/baywatch/config.VERSION=v${version}"
  ];
}
