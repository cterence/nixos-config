{
  self,
  ...
}:
let
  username = self.lib.username;
in
{
  flake.aspects =
    { aspects, ... }:
    {
      ${username} = {
        includes = with aspects; [
          terence-git
          terence-secrets
        ];

        generic =
          { pkgs, ... }:
          {
            users.users.${username} = {
              description = "Térence Chateigné";
              shell = pkgs.zsh;
            };
            programs.zsh.enable = true;

            home-manager.users."${username}".imports = [
              self.modules.homeManager."${username}"
            ];
          };

        nixos = {
          imports = [
            self.modules.generic.${username}
          ];
          users.users.${username} = {
            isNormalUser = true;
            description = "Térence Chateigné";
            extraGroups = [
              "docker"
              "networkmanager"
              "wheel"
              "keys"
              "i2c"
            ];
          };
        };

        darwin = {
          imports = [
            self.modules.generic.${username}
          ];
          users.users.${username}.home = "/Users/${username}";
        };

        homeManager = {
          home.username = username;
        };
      };

      "${username}-desktop" = {
        generic = {
          home-manager.users.${username}.imports = with self.modules.homeManager; [
            terence
            system-desktop
          ];
        };

        nixos = {
          imports = [
            self.modules.nixos.${username}
            self.modules.generic."${username}-desktop"
          ];
        };

        darwin = {
          imports = [
            self.modules.darwin.${username}
            self.modules.generic."${username}-desktop"
          ];
        };
      };

      "${username}-server".nixos = {
        imports = [
          self.modules.nixos.${username}
        ];

        home-manager.users.${username}.imports = with self.modules.homeManager; [
          terence
          system-server
        ];
      };
    };
}
