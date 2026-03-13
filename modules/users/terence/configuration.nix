{
  self,
  ...
}:
let
  username = "terence";
in
{
  flake.modules.nixos = {
    ${username} =
      { pkgs, ... }:
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

        home-manager.users."${username}".imports = [
          self.modules.homeManager."${username}"
        ];
      };

    "${username}-desktop" = {
      imports = [
        self.modules.nixos.${username}
      ];

      home-manager.users.${username}.imports = with self.modules.homeManager; [
        terence
        system-desktop
        system-personal
      ];
    };

    "${username}-server" = {
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
