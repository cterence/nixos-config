{
  lib,
  ...
}:
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
    "ssh"
    "tmux"
    "zsh"
  ];
  # Create a list of all the file paths in the userModulePath
  userModules = builtins.map (
    userModuleName: "${userModulePath}/${userModuleName}.nix"
  ) userModuleNames;
in
{
  imports = userModules;

  home = {
    username = "terence";
    homeDirectory = "/home/terence";
    stateVersion = "24.05";
    file = dotfilesAttrs;
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

  programs = {
    home-manager.enable = true;
    git.extraConfig.core.editor = lib.mkForce "nano";
  };
}
