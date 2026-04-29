{
  flake.modules.homeManager.browser =
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
