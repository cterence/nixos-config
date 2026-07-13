{ self, ... }: {
  flake-file.inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  flake.aspects.system-minimal = {
    generic = {
      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          substituters = [
            "https://cache.nixos.org?priority=10"
            "https://nix-community.cachix.org"
            "https://cache.numtide.com"
            "https://niks3.terence.cloud"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            "niks3.terence.cloud-1:YBjuY7HeSjKk5wmvw8N+vq/us2GxQPCHRn871lL7XL4="
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
          # Keep build deps around for offline/direnv/dev-shell reuse
          keep-outputs = true;
          keep-derivations = true;
        };
        extraOptions = ''
          warn-dirty = false
        '';
      };

      time.timeZone = "Europe/Paris";
    };

    nixos = { pkgs, ... }: {
      imports = [
        self.modules.generic.system-minimal
      ];

      boot.kernelPackages = pkgs.linuxPackages_latest;
      console.useXkbConfig = true;

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
    };

    darwin = {
      imports = [
        self.modules.generic.system-minimal
      ];

      nix = {
        settings = {
          max-jobs = "auto";
          extra-platforms = [
            "x86_64-darwin"
            "aarch64-darwin"
          ];
        };
        optimise.automatic = true;

        # Keep builds from starving the UI / audio: lower nix-daemon priority
        daemonProcessType = "Background";
        daemonIOLowPriority = true;

        # Weekly garbage collection on darwin (NixOS gets it via programs.nh)
        gc = {
          automatic = true;
          interval = {
            Weekday = 0;
            Hour = 3;
            Minute = 0;
          };
          options = "--delete-older-than 7d";
        };
      };
    };

    homeManager = {
      home = {
        stateVersion = "25.11";
      };
    };
  };
}
