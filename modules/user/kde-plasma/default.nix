_:

{
  # FIXME: doesn't do anything...
  programs = {
    plasma = {
      workspace = {
        colorScheme = "BreezeDark";
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "breeze-dark";
      };
      kwin = {
        effects = {
          minimization = {
            animation = "off";
          };
        };
      };
    };
  };
}
