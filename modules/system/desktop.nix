# Contains the common configurations across all my personal computers.
{ pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "intl";
      };
    };

    kbfs.enable = true;
    flatpak.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      air
      appimage-run
      chromium
      cobra-cli
      delve
      discord
      filezilla
      ghostty
      gimp
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      gpu-screen-recorder
      graphviz
      kitty
      libguestfs
      nfs-utils
      dc460ec7.libreoffice-fresh
      nvtopPackages.amd
      obsidian
      qemu
      spotify
      templ
      todoist-electron
      virt-manager
      vlc
      wireshark
      wl-clipboard
      zed-editor
    ];
  };

  fonts.packages =
    with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ]
    ++ (with pkgs.nerd-fonts; [
      fira-code
      jetbrains-mono
      droid-sans-mono
      meslo-lg
    ]);

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      ];
    };
    firefox.enable = true;
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

  hardware.graphics = {
    enable = true;
  };
}
