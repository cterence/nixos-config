{
  # Pin ddcutil 2.2.3. >=2.2.5 storms /dev/i2c-* with spurious display
  # events; on monitor-off this wedges PowerDevil (which blocks power
  # events) -> shutdown stalls. Workaround: downgrade. rockowitz/ddcutil#581.
  flake.overlays.ddcutil = _final: prev: {
    ddcutil = prev.ddcutil.overrideAttrs (_: rec {
      version = "2.2.3";
      src = prev.fetchurl {
        url = "https://www.ddcutil.com/tarballs/ddcutil-${version}.tar.gz";
        hash = "sha256-4XvAUqYvnqhS2eOLpPHtfnNmVnoOGdvhpDnuca2+BqA=";
      };
    });
  };
}
