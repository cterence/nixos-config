{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "playground";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "padok-team";
    repo = "playground";
    rev = "refs/tags/v${version}";
    hash = "sha256-Bqyp4rnuXIAGARsgXqVCrlQ9hY+m4Qk6sLdUsItiMUg=";
    private = true;
  };

  vendorHash = "sha256-2VR/WrsyPX4swuFCQwAUzqp8k1fbPTzAISe2YRk5Gu0=";

  postInstall = ''
    mv $out/bin/playground-operator $out/bin/playground
  '';
}
