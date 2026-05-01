{
  inputs,
  ...
}:
{
  flake.aspects =
    { aspects, ... }:
    {
      system-desktop = {
        includes = with aspects; [
          system-cli
          audio
          bluetooth
          networking
          kde
          keyboard
          printing
          browser
          desktop-apps
          development
          plasma-manager
        ];

        homeManager = {
          home = {
            # Cedilla fix
            # https://www.reddit.com/r/NixOS/comments/10hr5xo/add_bash_script_to_fix_gnome_issue_to_config_file/
            file.".XCompose".source = "${inputs.dotfiles}/.XCompose";
          };
        };
      };
    };
}
