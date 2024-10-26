# Contains the common configurations across all my personal computers.
{ pkgs, ... }:
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

  # security = {
  #   pam = {
  #     services = {
  #       login =
  #     };
  #   };
  # };

  programs = {
    ssh = {
      enableAskPassword = true;
      askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    };
  };

  environment = {
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
    };
    systemPackages = with pkgs; [
      kwallet-pam
      kdePackages.ksshaskpass
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
    ];
  };
}
