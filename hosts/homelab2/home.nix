{
  pkgs,
  lib,
  sops,
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
    "zsh"
  ];
  # Create a list of all the file paths in the userModulePath
  userModules = builtins.map (
    userModuleName: "${userModulePath}/${userModuleName}.nix"
  ) userModuleNames;
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

  systemd.user.services.kopia-sync = {
    Unit = {
      Description = "Sync remote Kopia repositories to filesystem repositories";
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "kopia-sync" ''
        #!/run/current-system/sw/bin/bash

        set -eu

        # Configuration
        BUCKET="velero-backup-tch"
        PATH_PREFIX="v1/kopia/"
        ENDPOINT="https://s3.eu-central-003.backblazeb2.com"
        LOCAL_BASE_DIR="/mnt/elements/kopia-sync/repositories"
        B2_KEY_ID="$(${pkgs.coreutils}/bin/cat ${sops.secrets.b2-velero-backup-tch-key-id.path})"
        B2_KEY="$(${pkgs.coreutils}/bin/cat ${sops.secrets.b2-velero-backup-tch-key.path})"
        KOPIA_PASSWORD="$(${pkgs.coreutils}/bin/cat ${sops.secrets.kopia-password.path})"

        # Ensure the local base directory exists
        ${pkgs.coreutils}/bin/mkdir -p "$LOCAL_BASE_DIR"

        export AWS_ACCESS_KEY_ID=$B2_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$B2_KEY

        # List all directories (repositories) in the bucket
        echo "Listing repositories in bucket..."
        REPOSITORIES=$(${pkgs.awscli2}/bin/aws s3 ls "$BUCKET/$PATH_PREFIX" --endpoint-url "$ENDPOINT" | ${pkgs.gawk}/bin/awk '/PRE/ {print $2}' | ${pkgs.gnused}/bin/sed 's:/$::')

        unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

        # Process each directory
        for REPO in $REPOSITORIES; do
            echo "Processing repository: $REPO"

            # Define paths
            REPO_REMOTE_PATH="s3://$BUCKET/$PATH_PREFIX$REPO"
            REPO_LOCAL_PATH="$LOCAL_BASE_DIR/$REPO"

            # Ensure the local repository directory exists
            ${pkgs.coreutils}/bin/mkdir -p "$REPO_LOCAL_PATH"

            # Connect Kopia to the repository
            echo "Connecting Kopia to repository: $REPO_REMOTE_PATH"
            ${pkgs.kopia}/bin/kopia repository connect b2 \
                --bucket="$BUCKET" \
                --key-id="$B2_KEY_ID" \
                --key="$B2_KEY" \
                --password="$KOPIA_PASSWORD" \
                --prefix="$PATH_PREFIX$REPO/" \
                --no-check-for-updates

            # Sync repository to local filesystem
            echo "Syncing repository: $REPO_REMOTE_PATH to $REPO_LOCAL_PATH"
            ${pkgs.kopia}/bin/kopia repository sync-to filesystem \
                --path="$REPO_LOCAL_PATH" \
                --parallel="32" \
                --delete

            # Disconnect Kopia from the repository to avoid conflicts
            echo "Disconnecting repository: $REPO_REMOTE_PATH"
            ${pkgs.kopia}/bin/kopia repository disconnect

        done

        echo "All repositories processed."
      ''}";
    };
  };
}
