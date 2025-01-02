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
            auth            optional        ${pkgs.kwallet-pam}/lib/security/pam_kwallet5.so
            session         optional        ${pkgs.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
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
    systemPackages =
      with pkgs;
      [
        kwallet-pam
      ]
      ++ (with kdePackages; [
        kalk
        ksshaskpass
      ]);
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
    ];
  };
}
