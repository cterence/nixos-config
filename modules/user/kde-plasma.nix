{ pkgs, ... }:

{
  programs = {
    plasma = {
      enable = true;
      input = {
        touchpads = [
          {
            enable = true;
            name = "PIXA3854:00 093A:0274 Touchpad";
            naturalScroll = true;
            productId = "0274";
            vendorId = "093a";
          }
        ];
      };
      kscreenlocker = {
        appearance = {
          wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Altai/contents/images/5120x2880.png";
        };
      };
      workspace = {
        enableMiddleClickPaste = true;
        colorScheme = "BreezeDark";
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "breeze-dark";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Altai/contents/images/5120x2880.png";
      };
      kwin = {
        effects = {
          minimization = {
            animation = "magiclamp";
          };
        };
        nightLight = {
          enable = true;
          mode = "constant";
          temperature.day = 4000;
        };
      };
    };
  };

  # Cedilla fix
  # https://www.reddit.com/r/NixOS/comments/10hr5xo/add_bash_script_to_fix_gnome_issue_to_config_file/
  home.file.".XCompose".text = ''
    include "/%L"

    <dead_acute> <c>			          : "ç"
    <Multi_key> <acute> <c>			    : "ç"
    <Multi_key> <apostrophe> <c>		: "ç"
    <Multi_key> <c> <apostrophe>		: "ç"
    <dead_acute> <C>			          : "Ç"
    <Multi_key> <acute> <C>			    : "Ç"
    <Multi_key> <apostrophe> <C>		: "Ç"
    <Multi_key> <C> <apostrophe>		: "Ç"
  '';
}
