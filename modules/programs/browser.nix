{
  flake.aspects.browser.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs = {
        firefox = {
          enable = true;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
        chromium.enable = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) true;
      };
    };
}
