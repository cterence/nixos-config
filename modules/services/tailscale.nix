{
  flake.modules.nixos.tailscale =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };

      environment.systemPackages = [
        pkgs.tailscale
        (lib.mkIf config.services.desktopManager.plasma6.enable pkgs.tail-tray)
      ];
    };
}
