# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

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
