{
  config,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.thunderbird ];
  programs.thunderbird = {
    enable = true;
    profiles.${config.home.username} = {
      isDefault = true;
    };
  };

  # TODO: create an option to specify the useraccounts
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
}
