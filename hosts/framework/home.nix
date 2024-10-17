{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  dotfilesPath = ../../dotfiles;
  userModulesPath = ../../modules/user;
  # Create a list of all the dotfiles in the dotfilesPath
  dotfilesAttrs = builtins.listToAttrs (
    map (dotfileName: {
      name = dotfileName;
      value = {
        source = "${dotfilesPath}/${dotfileName}";
      };
    }) (builtins.attrNames (builtins.readDir dotfilesPath))
  );
  # Create a list of all the file paths in the userModulesPath
  userModules = builtins.map (moduleName: "${userModulesPath}/${moduleName}") (
    builtins.attrNames (builtins.readDir userModulesPath)
  );
in
{
  imports = userModules ++ [
    inputs.nixos-work-config.nixosModules.home-manager
  ];

  # Overrides
  programs.awscli.settings = lib.mkForce {
    "default" = {
      region = "eu-west-3";
      output = "json";
    };
  };

  dconf = {
    settings = {
      "org/gnome/shell" = {
        favorite-apps = lib.mkForce [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "code.desktop"
          "kitty.desktop"
          "teams-for-linux.desktop"
          "slack.desktop"
          "thunderbird.desktop"
          "typora.desktop"
          "spotify.desktop"
          "todoist.desktop"
        ];
      };
    };
  };

  autostartPrograms = with pkgs; [
    slack
    teams-for-linux
    thunderbird
    todoist
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "terence";
    homeDirectory = "/home/terence";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = dotfilesAttrs;

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/terence/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      AWS_PAGER = "jq";
      BINDIR = "$HOME/.local/bin";
      EDITOR = "nano";
      KUBE_EDITOR = "code --wait";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
  };
}
