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
          pinentry = {
            package = pkgs.kwalletcli;
            program = "pinentry-kwallet";
          };
        };
      };
      programs.gpg = {
        enable = true;
      };
    };
}
