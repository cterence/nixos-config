{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    autostartPrograms = lib.mkOption {
      description = "Applications to start automatically when the user logs in.";
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        signal-desktop
        thunderbird
      ];
    };
  };
  config.home.file = builtins.listToAttrs (
    map (pkg: {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
        if pkg ? desktopItem then
          {
            # Application has a desktopItem entry.
            # Assume that it was made with makeDesktopEntry, which exposes a
            # text attribute with the contents of the .desktop file
            text = pkg.desktopItem.text;
            # } else if pkg.pname == "nextcloud-client" then {
            #   # Edge case for nextcloud-client, which has a different name for the .desktop file
            #   source = (pkg + "/share/applications/com.nextcloud.desktopclient.nextcloud.desktop");
          }
        else
          {
            # Application does *not* have a desktopItem entry. Try to find a
            # matching .desktop name in /share/applications
            source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
          };
    }) config.autostartPrograms
  );
}
