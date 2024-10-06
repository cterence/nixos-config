# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "amdgpu" ];

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "intl";
      };
    };

    udev.packages = with pkgs; [ gnome-settings-daemon ];
    kbfs.enable = true;
    flatpak.enable = true;
  };
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      air
      avidemux
      chromium
      cobra-cli
      discord
      filezilla
      gimp
      gnome-tweaks
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      gpu-screen-recorder
      kitty
      libguestfs
      libreoffice-fresh
      nvtopPackages.amd
      qemu
      spotify
      templ
      tesseract
      todoist-electron
      virt-manager
      vlc
      wireshark
      zed-editor
    ];

    gnome.excludePackages = (
      with pkgs;
      [
        atomix
        cheese
        epiphany
        geary
        gnome-music
        gnome-photos
        gnome-tour
        hitori
        iagno
        tali
        totem
      ]
    );
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "JetBrainsMono"
        "Meslo"
      ];
    })
  ];

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      ];
    };
    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    firefox.enable = true;
    wireshark.enable = true;
  };

  hardware.graphics = {
    enable = true;
  };
}
