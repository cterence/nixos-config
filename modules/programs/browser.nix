{
  flake.aspects.browser.homeManager =
    { config, ... }:
    {
      programs = {
        firefox = {
          enable = true;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
        chromium.enable = true;
      };
    };
}
