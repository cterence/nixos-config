{
  buildGoModule,
}:
buildGoModule {
  pname = "pinned-sweep";
  version = "0.1.0";
  src = ./.;
  vendorHash = null;

  meta = {
    description = "Sweep multiverse pins against Hydra build status";
    mainProgram = "pinned-sweep";
  };
}
