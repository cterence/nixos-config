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
            program = "pinentry-kwallet";
          };
        };
      };
      programs.gpg = {
        enable = true;
      };
    };
}
