{ lib, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = "Térence Chateigné";
      userEmail = lib.mkDefault "terence.chateigne@posteo.net";
      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "code --wait";
        credential.helper = "store";
        pull.ff = "only";
        log = {
          abbrevCommit = true;
          follow = true;
          decorate = false;
        };
        push = {
          default = "upstream";
          followTags = true;
          autoSetupRemote = true;
        };
        rebase.autoStash = true;
        help.autocorrect = 20;
      };
    };
    gh.enable = true;
  };
}
