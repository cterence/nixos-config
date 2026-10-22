{ self, ... }:
{
  # Finder sync ext needs a full Xcode, absent on Hydra (nixpkgs#563742).
  flake.overlays.opencloud-desktop = _final: prev: {
    opencloud-desktop = prev.opencloud-desktop.overrideAttrs (_: {
      cmakeFlags = [ "-DBUILD_SHELL_INTEGRATION=OFF" ];
    });
  };
}
