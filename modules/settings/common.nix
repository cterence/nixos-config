{
  flake.modules.nixos.common-settings =
    { pkgs, config, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;

      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          substituters = [
            "https://cache.nixos.org?priority=10"
            "https://install.determinate.systems"
            "https://nix-community.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM"
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          auto-optimise-store = true;
          download-buffer-size = 1024 * 1024 * 1024;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
        extraOptions = ''
          warn-dirty = false
          keep-outputs = true
          !include ${config.sops.secrets.nixos-access-tokens.path}
        '';
      };

      time.timeZone = "Europe/Paris";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };

      services = {
        xserver.xkb = {
          layout = "us";
          variant = "alt-intl";
        };
        udev.extraRules = ''
          # MonsGeek M1/M-series HID rule
          KERNEL=="hidraw*", ATTRS{idVendor}=="fffe", ATTRS{idProduct}=="0005", MODE="0666", GROUP="users"
        '';
      };

      console.useXkbConfig = true;

      security.rtkit.enable = true;

      programs.nix-ld.enable = true;
    };
}
