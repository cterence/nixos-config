# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.enable = true;
    udev.packages = with pkgs; [ gnome-settings-daemon ];
  };

  environment = {
    systemPackages = with pkgs; [
      gnome-tweaks
    ];

    gnome.excludePackages = with pkgs; [
      atomix
      cheese
      epiphany
      geary
      gnome-music
      gnome-photos
      gnome-tour
      hitori
      iagno
      tali
      totem
    ];
  };
}
