{
  flake.modules.homeManager.desktop-apps =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        appimage-run
        audacity
        calibre
        gpu-screen-recorder
        libreoffice-fresh
        local.linear-linux
        nextcloud-client
        obsidian
        picard
        qbittorrent
        qemu
        signal-desktop
        supersonic
        todoist-electron
        vlc
      ];

      programs.thunderbird = {
        enable = true;
        profiles.${config.home.username} = {
          isDefault = true;
        };
      };

      accounts.email = {
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
    };
}
