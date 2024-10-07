{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "baywatch";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "padok-team";
    repo = "baywatch";
    rev = "refs/tags/v${version}";
    hash = "sha256-GVMBj/9obedLbwXSqY1yK9Tvcnc7zSNQBZyfdSOc394=";
    private = true;
  };

  vendorHash = "sha256-WOdaq8EhcDs9PTTclAhmji9+TtyxklYXLaSJnHrSyo4=";

  ldflags = [
    "-s"
    "-X github.com/padok-team/baywatch/config.VERSION=v${version}"
  ];
}
