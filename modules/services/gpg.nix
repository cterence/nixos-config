{
  flake.modules.homeManager.gpg =
    { pkgs, ... }:
    {
      services = {
        ## Enable gpg-agent with ssh support
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          # pinentry is a collection of simple PIN or passphrase dialogs used for
          # password entry
          pinentry.package = pkgs.pinentry-qt;
        };
      };
      programs.gpg = {
        enable = true;
      };
    };
}
