{
  flake.aspects.gpg.homeManager =
    { pkgs, ... }:
    {
      services = {
        ## Enable gpg-agent with ssh support
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          pinentry = {
            package = pkgs.pinentry-qt;
          };
        };
      };

      programs = {
        gpg = {
          enable = true;
        };
      };

      home = {
        sessionVariables = {
          PINENTRY_KDE_USE_WALLET = "1";
        };
      };
    };
}
