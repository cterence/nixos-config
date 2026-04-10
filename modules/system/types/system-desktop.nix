{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.system-desktop = {
    imports = with self.modules.nixos; [
      system-cli
      audio
      bluetooth
      networking
      kde
      keyboard
      printing
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with self.modules.homeManager; [
      system-cli
      browser
      desktop-apps
      development
      plasma-manager
      tailscale
    ];

    home = {
      # Cedilla fix
      # https://www.reddit.com/r/NixOS/comments/10hr5xo/add_bash_script_to_fix_gnome_issue_to_config_file/
      file.".XCompose".source = "${inputs.dotfiles}/.XCompose";
    };
  };
}
