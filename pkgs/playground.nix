{
  buildGoModule,
}:

buildGoModule rec {
  pname = "playground";
  version = "0.1.1";

  src = builtins.fetchGit {
    url = "git@github.com:padok-team/playground.git";
    ref = "refs/tags/v${version}";
    rev = "3245e28c8b20ecb9c804bd54d2bb2ebaf1ee301e";
  };

  vendorHash = "sha256-2VR/WrsyPX4swuFCQwAUzqp8k1fbPTzAISe2YRk5Gu0=";

  postInstall = ''
    mv $out/bin/playground-operator $out/bin/playground
  '';
}
