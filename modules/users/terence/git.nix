let
  username = "terence";
in
{
  flake.aspects."${username}-git".homeManager = {
    programs = {
      git = {
        enable = true;
        settings = {
          user = {
            name = "Térence Chateigné";
            email = "terence.chateigne@posteo.net";
            signingkey = "FD05F9D023BE3DBA";
          };
          commit.gpgsign = true;
          tag.gpgsign = true;
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
