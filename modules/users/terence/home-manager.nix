{
  inputs,
  self,
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
      ++ (with self.modules.homeManager; [
        cli-tools
        gpg
        homelab-client-cert
        shell
      ])
      ++ (lib.optionals osConfig.services.desktopManager.plasma6.enable (
        with self.modules.homeManager;
        [
          browser
          desktop-apps
          development
          plasma-manager
          tailscale
        ]
      ))
      ++ (lib.optionals (lib.hasPrefix "homelab" osConfig.networking.hostName) (
        with self.modules.homeManager;
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
