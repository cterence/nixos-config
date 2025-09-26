# Contains the common configurations across all my systems.
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:

{
  # Select internationalisation properties.
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

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware = {
    bluetooth.enable = true;
  };
  security.rtkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [
      "127.0.0.1" # Remove if using dnscrypt-proxy2
      "::1"
    ];
    networkmanager.dns = "none";
    # Use dnsmasq as a DNS server when trying to connect to a captive portal (remove nameservers and disable dnscrypt-proxy2 as well)
    # networkmanager.dns = "dnsmasq";

    firewall = {
      enable = false;
      allowedTCPPorts = [
        80
        443
        6443
        9443
      ];
      allowedUDPPorts = [
        53
      ];
      extraCommands = ''
        ip6tables --table nat --flush OUTPUT
        ${lib.flip (lib.concatMapStringsSep "\n") [ "udp" "tcp" ] (proto: ''
          ip6tables --table nat --append OUTPUT \
            --protocol ${proto} --destination ::1 --destination-port 53 \
            --jump REDIRECT --to-ports 51
        '')}
      '';
    };
  };

  # Fix for https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd = {
    services = {
      dnscrypt-proxy2.serviceConfig = {
        StateDirectory = "dnscrypt-proxy";
      };
      NetworkManager-wait-online.serviceConfig.ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];
      nix-daemon.serviceConfig.EnvironmentFile = "/etc/nixos/nix-daemon-environment";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      argocd
      attic-client
      awscli2
      bash
      bat
      bc
      btop
      cmctl
      code-server
      cryptsetup
      dig
      docker-buildx
      du-dust
      efibootmgr
      entr
      eza
      fd
      ffmpeg
      file
      glab
      gnumake
      ipcalc
      killall
      kind
      kopia
      krew
      kubectl
      kubernetes-helm
      libva-utils
      lm_sensors
      lsof
      manix
      mariadb-client
      mlocate
      net-tools
      neofetch
      neovim
      nil
      nix-init
      nix-prefetch
      nix-update
      nixd
      nixfmt-rfc-style
      nmap
      nodejs_20
      nurl
      openssl
      pciutils
      postgresql
      powertop
      pre-commit
      pv-migrate
      python313
      rclone
      socat
      sops
      tcpdump
      tfautomv
      tfswitch
      tgswitch
      tig
      tmux
      tree
      unzip
      usbutils
      vim
      wget
      whois
      yarn
      yq
      zig
      zip
    ];
    pathsToLink = [ "/share/zsh" ];
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.terence = {
      isNormalUser = true;
      home = "/home/terence";
      description = "Térence Chateigné";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "input"
        "kvm"
      ];
    };
  };

  services = {
    pulseaudio.enable = false;
    openssh.enable = true;
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
    # Allow /bin/bash to be used as a shell for scripts
    # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673/63
    envfs.enable = true;

    dnscrypt-proxy = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        # server_names = [ ... ];
      };
    };

    fwupd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs = {
    mtr.enable = true;
    nix-index-database.comma.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/terence/nixos";
    };

    gnupg.agent = {
      enable = true;
    };

    zsh = {
      enable = true;
      shellInit = ''
        export GH_TOKEN="$(cat ${config.sops.secrets.gh-cli-token.path})"
        export GITLAB_TOKEN="$(cat ${config.sops.secrets.glab-cli-token.path})"
      '';
    };

    # Check envfs comment
    nix-ld.enable = true;
  };

  sops = {
    age.keyFile = config.users.users.terence.home + "/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      "gh-cli-token" = {
        mode = "0440";
        group = config.users.groups.keys.name;
        owner = config.users.users.terence.name;
      };
      "glab-cli-token" = {
        mode = "0440";
        group = config.users.groups.keys.name;
        owner = config.users.users.terence.name;
      };
      "nixos-access-tokens" = {
        mode = "0440";
        group = config.users.groups.keys.name;
        owner = config.users.users.terence.name;
      };
      "nix-daemon-environment" = {
        path = "/etc/nixos/nix-daemon-environment";
        mode = "0440";
        group = config.users.groups.keys.name;
        owner = config.users.users.terence.name;
      };
    };
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = 524288000; # 500MB
      trusted-users = [
        "root"
        "terence"
      ];
    };
    extraOptions = ''
      !include ${config.sops.secrets.nixos-access-tokens.path}
    '';
  };

  time.timeZone = "Europe/Paris";
}
