{ self, ... }: {
  flake.aspects.tailscale = {
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

    darwin = {
      imports = [
        self.modules.generic.tailscale
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
}
