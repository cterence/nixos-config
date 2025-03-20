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

  security = {
    pam = {
      services = {
        sddm = {
          text = ''
            auth            optional        ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so
            session         optional        ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
          '';
        };
      };
    };
  };

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
    systemPackages = with pkgs.kdePackages; [
      kwallet-pam
      kalk
      ksshaskpass
      partitionmanager
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      plasma-browser-integration
    ];
  };
}
