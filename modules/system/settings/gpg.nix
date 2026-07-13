{
  flake.aspects.gpg.homeManager =
    { pkgs, lib, ... }:
    {
      services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        ## Enable gpg-agent with ssh support
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          pinentry = {
            package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.pinentry-qt else pkgs.pinentry_mac;
          };
        };
      };

      programs = {
        gpg = {
          enable = true;
        };
      };

      home = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        sessionVariables = {
          PINENTRY_KDE_USE_WALLET = "1";
        };
      };
    };
}
