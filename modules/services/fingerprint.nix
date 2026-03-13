{
  flake.modules.nixos.fingerprint = {
    services.fprintd.enable = true;
    security.pam.services = {
      login.fprintAuth = false;
      sddm.fprintAuth = true;
    };
  };
}
