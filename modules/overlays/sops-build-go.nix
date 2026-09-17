{
  flake.overlays.sops-build-go = _final: prev: {
    buildGo125Module = prev.buildGoModule;
  };
}
