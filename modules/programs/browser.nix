{
  flake.modules.homeManager.browser = {
    programs = {
      firefox = {
        enable = true;
      };
      chromium.enable = true;
    };
  };
}
