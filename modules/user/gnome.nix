{ lib, pkgs, ... }:

{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        monospace-font-name = "MesloLGS Nerd Font 10";
        enable-hot-corners = false;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "Vitals@CoreCoding.com"
          "dash-to-panel@jderose9.github.com"
          "sound-output-device-chooser@kgshank.net"
          "appindicatorsupport@rgcjonas.gmail.com"
          "tailscale-status@maxgallup.github.com"
          "display-brightness-ddcutil@themightydeity.github.com"
        ];

        favorite-apps = [
          "firefox.desktop"
          "code.desktop"
          "com.mitchellh.ghostty.desktop"
          "org.gnome.Nautilus.desktop"
          "thunderbird.desktop"
          "spotify.desktop"
          "supersonic.desktop"
          "obsidian.desktop"
          "todoist.desktop"
        ];
      };
      "org/gnome/shell/extensions/dash-to-panel" = {
        panel-positions = ''{"0":"BOTTOM","1":"BOTTOM"}'';
        multi-monitors = false;
        appicon-margin = 2;
        appicon-padding = 6;
        trans-bg-color = "#241f31";
        dot-style-focused = "DASHES";
        dot-style-unfocused = "SQUARES";
      };

      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_processor_usage_"
          "_memory_allocated_"
          "_storage_used_"
          "__network-rx_max__"
          "__network-tx_max__"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "ghostty";
        name = "ghostty";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/desktop/input-sources" = {
        sources = with lib.hm.gvariant; [
          (mkTuple [
            "xkb"
            "us+alt-intl"
          ])
        ];
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
      };

      # Drag to top to maximize
      "org/gnome/mutter" = {
        edge-tiling = true;
        experimental-features = "['scale-monitor-framebuffer']";
      };

      "org/gnome/settings-daemon/plugins/power" = {
        ambient-enabled = false;
      };
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.appindicator
  ];

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
