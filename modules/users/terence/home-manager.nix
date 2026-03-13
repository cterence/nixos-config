let
  username = "terence";
in
{
  flake.modules.homeManager.${username} = {
    home.username = username;
  };
}
