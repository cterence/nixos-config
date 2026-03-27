{ inputs, self, ... }:
{
  flake.modules.nixos.kde =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        fonts
      ];

      services = {
        xserver.enable = false;
        displayManager.sddm.enable = true;
        desktopManager.plasma6.enable = true;
      };

      environment = {
        systemPackages =
          with pkgs.kdePackages;
          [
            kate
            kalk
            ksshaskpass
            kwallet-pam
            partitionmanager
          ]
          ++ [
            inputs.plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];

        plasma6.excludePackages = with pkgs.kdePackages; [
          elisa
          plasma-browser-integration
          discover
        ];

        variables = {
          SSH_ASKPASS_REQUIRE = "prefer";
        };
      };

      programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
      };

      home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
    };

  flake.modules.homeManager.plasma-manager = {
    programs.plasma = {
      enable = true;
      input = {
        touchpads = [
          {
            enable = true;
            name = "PIXA3854:00 093A:0274 Touchpad";
            naturalScroll = true;
            productId = "0274";
            vendorId = "093a";
          }
        ];
      };
      workspace = {
        enableMiddleClickPaste = true;
        colorScheme = "BreezeDark";
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "breeze-dark";
      };
      kwin = {
        effects = {
          minimization = {
            animation = "magiclamp";
          };
        };
        nightLight = {
          enable = true;
          mode = "constant";
          temperature.day = 4000;
        };
      };
    };
  };
}
