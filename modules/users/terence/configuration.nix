{
  inputs,
  ...
}:
let
  username = "terence";
in
{
  flake.modules.nixos.${username} =
    { config, pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        description = "Térence Chateigné";
        extraGroups = [
          "docker"
          "networkmanager"
          "wheel"
          "keys"
        ];
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;

      home-manager = {
        users."${username}" = {
          imports = [
            inputs.self.modules.homeManager."${username}"
          ];
        };

        sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
      };
    };
}
