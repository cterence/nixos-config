let
  username = "terence";
in
{
  flake.modules.homeManager.${username} = {
    programs = {
      git = {
        enable = true;
        settings = {
          user = {
            name = "Térence Chateigné";
            email = "terence.chateigne@posteo.net";
          };
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
  };
}
