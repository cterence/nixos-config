{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font.name = "MesloLGS Nerd Font";
    settings = {
      hide_window_decorations = "no";
      enabled_layouts = "grid";
    };
    keybindings = {
      "ctrl+shift+enter" = "new_window_with_cwd";
    };
  };
}
