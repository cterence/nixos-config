{ self, ... }: {
  flake = {
    overlays.tailscale-gui = _final: prev: {
      tailscale-gui = prev.tailscale-gui.overrideAttrs {
        version = "1.98.10";
        src = prev.fetchurl {
          url = "https://pkgs.tailscale.com/stable/Tailscale-1.98.10-macos.pkg";
          hash = "sha256-wur19mCtRaZNG6Q+5yQBAppcsG5tFIxekKmHpvVGvFg=";
        };
      };
    };
    aspects.tailscale = {
      generic =
        { pkgs, ... }:
        {
          services.tailscale = {
            enable = true;
          };
          environment.systemPackages = [ pkgs.tailscale ];
        };

      nixos = {
        imports = [
          self.modules.generic.tailscale
        ];
        services.tailscale = {
          useRoutingFeatures = "client";
          extraDaemonFlags = [ "--no-logs-no-support" ];
          extraUpFlags = [ "--accept-dns=false" ];
        };
      };

      darwin = { pkgs, ... }: {
        imports = [
          self.modules.generic.tailscale
        ];

        nixpkgs.overlays = [
          self.overlays.tailscale-gui
        ];

        environment.systemPackages = [
          pkgs.tailscale-gui
        ];
      };

      homeManager =
        {
          pkgs,
          lib,
          osConfig,
          ...
        }:
        let
          plasma6Enabled = lib.attrByPath [ "services" "desktopManager" "plasma6" "enable" ] false osConfig;
        in
        {
          home.packages = with pkgs; [
            (lib.mkIf plasma6Enabled tail-tray)
          ];

          xdg.configFile."autostart/tail-tray.desktop" = lib.mkIf plasma6Enabled {
            text = ''
              [Desktop Entry]
              Categories=Qt;KDE;Utility;X-Networking;X-Internet;X-VPN;
              Comment=Tailscale Tray Application
              Exec=${pkgs.tail-tray}/bin/tail-tray
              GenericName=Tail Tray
              Icon=tail-tray
              Name=Tail Tray
              NoDisplay=false
              StartupNotify=true
              Terminal=false
              Type=Application
              X-DarkIcon=tail-tray-dark
              X-LightIcon=tail-tray
            '';
          };
        };
    };
  };
}
