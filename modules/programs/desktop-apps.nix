{ inputs, ... }: {
  flake-file.inputs = {
    nixpkgs-linker-failure-guard.url = "github:nixos/nixpkgs/30945d3c58d70fbec6efe10d56362a35e7a64507";
  };

  flake.aspects.desktop-apps = {
    darwin = {
      environment.systemPackages = [
        inputs.nixpkgs-linker-failure-guard.legacyPackages.aarch64-darwin.rectangle
      ];
    };

    homeManager =
      {
        config,
        pkgs,
        lib, # Make sure lib is pulled in here
        ...
      }:
      {
        home.packages =
          with pkgs;
          [
            obsidian
            picard
            signal-desktop
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            audacity
            appimage-run
            calibre
            gpu-screen-recorder
            libreoffice-fresh
            supersonic
            qbittorrent
            qemu
            todoist-electron
            vlc
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            inputs.nixpkgs-linker-failure-guard.legacyPackages.aarch64-darwin.supersonic
            inputs.nixpkgs-linker-failure-guard.legacyPackages.aarch64-darwin.qbittorrent
          ];

        programs.thunderbird = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          enable = true;
          profiles.${config.home.username} = {
            isDefault = true;
          };
        };

        accounts.email = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          accounts.Posteo = {
            realName = "Térence Chateigné";
            address = "terence.chateigne@posteo.net";
            userName = "terence.chateigne@posteo.net";
            primary = true;
            imap = {
              host = "posteo.de";
              port = 993;
            };
            thunderbird = {
              enable = true;
              profiles = [ "${config.home.username}" ];
            };
          };
          accounts.Gmail = {
            realName = "Térence Chateigné";
            address = "terence.chateigne@gmail.com";
            userName = "terence.chateigne@gmail.com";
            flavor = "gmail.com";
            imap = {
              host = "imap.gmail.com";
              port = 993;
            };
            thunderbird = {
              enable = true;
              profiles = [ "${config.home.username}" ];
              settings = id: {
                # OAuth method ID, check https://github.com/nix-community/home-manager/issues/4988
                "mail.server.server_${id}.authMethod" = 10;
                "mail.smtpserver.smtp_${id}.authMethod" = 10;
              };
            };
          };
        };

        # Guard the XDG configuration block entirely from macOS
        xdg.configFile = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          "autostart/Nextcloud.desktop".text = ''
            [Desktop Entry]
            Name=Nextcloud
            GenericName=File Synchronizer
            Exec=${pkgs.nextcloud-client}/bin/nextcloud --background
            Terminal=false
            Icon=Nextcloud
            Categories=Network
            Type=Application
            StartupNotify=false
            X-GNOME-Autostart-enabled=true
            X-GNOME-Autostart-Delay=10
          '';

          "autostart/thunderbird.desktop".text = ''
            [Desktop Entry]
            Actions=profile-manager-window
            Categories=Network;Chat;Email;Feed;GTK;News
            Comment=Read and write e-mails or RSS feeds, or manage tasks on calendars.
            Exec=${pkgs.thunderbird}/bin/thunderbird --name thunderbird %U
            GenericName=Email Client
            Icon=thunderbird
            Keywords=mail;email;e-mail;messages;rss;calendar;address book;addressbook;chat
            MimeType=message/rfc822;x-scheme-handler/mailto;text/calendar;text/x-vcard
            Name=Thunderbird
            StartupNotify=true
            StartupWMClass=thunderbird
            Terminal=false
            Type=Application
            Version=1.5

            [Desktop Action profile-manager-window]
            Exec=${pkgs.thunderbird}/bin/thunderbird --ProfileManager
            Name=Profile Manager
          '';
        };
      };
  };
}
