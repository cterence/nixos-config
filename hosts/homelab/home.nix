{ pkgs, lib, ... }:
let
  dotfilesPath = ../../dotfiles;
  userModulePath = ../../modules/user;
  # Create a list of all the dotfiles in the dotfilesPath
  dotfilesAttrs = builtins.listToAttrs (
    map (dotfileName: {
      name = dotfileName;
      value = {
        source = "${dotfilesPath}/${dotfileName}";
      };
    }) (builtins.attrNames (builtins.readDir dotfilesPath))
  );
  userModuleNames = [
    "awscli"
    "direnv"
    "fzf"
    "git"
    "go"
    "htop"
    "jq"
    "k9s"
    "zsh"
  ];
  # Create a list of all the file paths in the userModulePath
  userModules = builtins.map (userModuleName: "${userModulePath}/${userModuleName}.nix") (
    userModuleNames
  );
in
{
  imports = userModules;

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
      (pkgs.writeShellScriptBin "syncelem" ''
        set -e
        sudo cryptsetup luksOpen /dev/sdb1 elements
        sudo mount /dev/mapper/elements /mnt/elements
        sudo rsync -av --delete /mnt/mx500/k8s/openebs/local/ /mnt/elements
        sudo umount /mnt/elements
        sudo cryptsetup luksClose elements
      '')
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
      FZF_BASE = "$HOME/.nix-profile/bin";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.krew/bin"
      "$HOME/go/bin"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    git.extraConfig.core.editor = lib.mkForce "nano";
  };
}