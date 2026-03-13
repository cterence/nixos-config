{
  flake.modules.nixos.tailscale =
    { pkgs, ... }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
        extraDaemonFlags = [ "--no-logs-no-support" ];

      };
      environment.systemPackages = [ pkgs.tailscale ];
    };

  flake.modules.homeManager.tailscale =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      home.packages = with pkgs; [
        (lib.mkIf osConfig.services.desktopManager.plasma6.enable tail-tray)
      ];

      xdg.configFile."autostart/tail-tray.desktop".text = ''
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
}
