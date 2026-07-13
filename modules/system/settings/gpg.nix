{
  flake.aspects.gpg.homeManager =
    { pkgs, lib, ... }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
    {
      ## Enable gpg-agent with ssh support on both Linux and Darwin
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        enableZshIntegration = true;
        pinentry = {
          package = if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
        };
      };

      programs = {
        gpg = {
          enable = true;
        };
      };

      home = lib.mkIf (!isDarwin) {
        sessionVariables = {
          PINENTRY_KDE_USE_WALLET = "1";
        };
      };
    };
}
