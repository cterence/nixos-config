{
  inputs,
  lib,
  ...
}:
let
  username = "terence";
in
{
  flake.modules.homeManager."${username}" =
    { osConfig, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ]
      ++ (with inputs.self.modules.homeManager; [
        cli-tools
        homelab-client-cert
        shell
      ])
      ++ (lib.optionals osConfig.services.desktopManager.plasma6.enable (
        with inputs.self.modules.homeManager;
        [
          browser
          desktop-apps
          development
          plasma-manager
        ]
      ))
      ++ (lib.optionals (osConfig.networking.hostName == "homelab2") (
        with inputs.self.modules.homeManager;
        [
          kopia-sync
          tmux
        ]
      ));

      home = {
        username = "${username}";
        stateVersion = "25.11";

        # Cedilla fix
        # https://www.reddit.com/r/NixOS/comments/10hr5xo/add_bash_script_to_fix_gnome_issue_to_config_file/
        file.".XCompose".source = "${inputs.dotfiles}/.XCompose";
      };
    };
}
