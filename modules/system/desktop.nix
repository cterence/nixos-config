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
    gnome.gcr-ssh-agent.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      air
      appimage-run
      chromium
      cobra-cli
      (code-cursor.overrideAttrs (previousAttrs: {
        postFixup = previousAttrs.postFixup + ''
          sed -i -e "s|StartupWMClass=.*|StartupWMClass=cursor-url-handler|" $out/share/applications/cursor-url-handler.desktop
        '';
      }))
      ddcutil
      delve
      discord
      filezilla
      gimp
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ])
      gpu-screen-recorder
      graphviz
      kdiskmark
      libguestfs
      nix-alien
      nfs-utils
      libreoffice-fresh
      nvtopPackages.amd
      obsidian
      qemu
      spotify
      supersonic
      templ
      todoist-electron
      undollar
      virt-manager
      vlc
      wireshark
      wl-clipboard
      (
        let
          base = pkgs.appimageTools.defaultFhsEnvArgs;
        in
        pkgs.buildFHSEnv (
          base
          // {
            name = "fhs";
            targetPkgs =
              pkgs:
              # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
              # lacking many basic packages needed by most software.
              # Therefore, we need to add them manually.
              #
              # pkgs.appimageTools provides basic packages required by most software.
              (base.targetPkgs pkgs)
              ++ (with pkgs; [
                pkg-config
                ncurses
                # Feel free to add more packages here if needed.
              ]);
            profile = "export FHS=1";
            runScript = "bash";
            extraOutputsToInstall = [ "dev" ];
          }
        )
      )
    ];
  };

  fonts = {
    packages =
      with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
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
    fontconfig.useEmbeddedBitmaps = true; # https://discourse.nixos.org/t/firefox-doesnt-render-noto-color-emojis/51202
  };

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      ];
    };
    firefox.enable = true;
    gpu-screen-recorder.enable = true;
  };

  hardware.graphics = {
    enable = true;
  };
}
