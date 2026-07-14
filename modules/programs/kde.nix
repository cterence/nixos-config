{ inputs, ... }:
{
  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  flake.aspects =
    { aspects, ... }:
    {
      kde = {
        includes = with aspects; [ fonts ];
        nixos =
          { pkgs, ... }:
          {
            services = {
              # Required by X11 greeter (asserts xserver || sddm.wayland).
              xserver.enable = true;
              displayManager.sddm = {
                enable = true;
                # X11 greeter: kwin_wayland greeter can stick on a 0x0
                # placeholder if DRM outputs aren't ready. bazzite#4826.
                # Session stays Wayland.
                wayland.enable = false;
              };
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

          };
      };

      plasma-manager.homeManager = { lib, pkgs, ... }: {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
        programs = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
          plasma = {
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
      };
    };
}
