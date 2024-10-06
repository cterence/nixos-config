# Contains the common configurations across all my systems.
{ pkgs, ... }:

{
  # Select internationalisation properties.
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

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware.pulseaudio.enable = false;
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
      "127.0.0.1"
      "::1"
    ];
    networkmanager.dns = "none";

    firewall.enable = false;
  };

  # Fix for https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      awscli2
      bash
      code-server
      cryptsetup
      dig
      efibootmgr
      ffmpeg
      gnumake
      kind
      krew
      kubectl
      kubernetes-helm
      libva-utils
      lsof
      mlocate
      neofetch
      neovim
      nil
      nixd
      nixfmt-rfc-style
      nmap
      nodejs_20
      openssl
      pciutils
      python3Full
      sops
      tfswitch
      tgswitch
      tree
      unzip
      usbutils
      vim
      wget
      whois
      yarn
      yq
      zig
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
        "libvirt"
        "kvm"
      ];
    };
  };

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
    # Allow /bin/bash to be used as a shell for scripts
    # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673/63
    envfs.enable = true;

    dnscrypt-proxy2 = {
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

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
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
      enableSSHSupport = true;
    };

    zsh.enable = true;

    # Check envfs comment
    nix-ld.enable = true;
  };

  nix = {
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 30d";
      randomizedDelaySec = "1 hour";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  time.timeZone = "Europe/Paris";
}
