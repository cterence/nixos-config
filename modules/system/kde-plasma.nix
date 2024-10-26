# Contains the common configurations across all my personal computers.
{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    xserver.enable = false;
  };

  # environment = {
  #   plasma6.excludePackages = with pkgs.kdePackages; [
  #     plasma-browser-integration
  #     konsole
  #     elisa
  #   ];
  # };
}
