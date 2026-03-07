{
  inputs,
  ...
}:
let
  username = "terence";
in
{
  flake.modules.homeManager."${username}" = {
    imports =
      with inputs.self.modules.homeManager;
      [
        browser
        cli-tools
        homelab-client-cert
        desktop-apps
        development
        plasma-manager
        shell
      ]
      ++ [
        inputs.sops-nix.homeManagerModules.sops
      ];

    home = {
      username = "${username}";
      stateVersion = "25.11";

      # Cedilla fix
      # https://www.reddit.com/r/NixOS/comments/10hr5xo/add_bash_script_to_fix_gnome_issue_to_config_file/
      file.".XCompose".text = ''
        include "/%L"

        <dead_acute> <c>			          : "ç"
        <Multi_key> <acute> <c>			    : "ç"
        <Multi_key> <apostrophe> <c>		: "ç"
        <Multi_key> <c> <apostrophe>		: "ç"
        <dead_acute> <C>			          : "Ç"
        <Multi_key> <acute> <C>			    : "Ç"
        <Multi_key> <apostrophe> <C>		: "Ç"
        <Multi_key> <C> <apostrophe>		: "Ç"
      '';
    };
  };
}
