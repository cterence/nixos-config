{
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  flake.modules.nixos.system-minimal =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;

      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          substituters = [
            "https://cache.nixos.org?priority=10"
            "https://nix-community.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
        '';
      };

      time.timeZone = "Europe/Paris";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
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
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "alt-intl";
      };

      console.useXkbConfig = true;
    };

  flake.modules.homeManager.system-minimal = {
    home = {
      stateVersion = "25.11";
    };
  };
}
