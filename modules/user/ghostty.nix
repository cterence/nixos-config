{
  # https://github.com/ghostty-org/ghostty/discussions/8899#discussioncomment-14717979
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      theme = "Abernathy";
      env = [ "GTK_IM_MODULE=ibus" ];
    };
  };
}
