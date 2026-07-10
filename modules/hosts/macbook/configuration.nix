{ self, ... }:
let
  hostname = "macbook";
in
{
  flake-file.inputs = {
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.darwinConfigurations = self.lib.mkDarwin "aarch64-darwin" hostname;

  flake.aspects =
    { aspects, ... }:
    {
      ${hostname} = {
        includes = with aspects; [
          system-macos
          system-desktop
          system-personal
          terence-desktop
        ];

        darwin = {
          networking.hostName = hostname;
          system.stateVersion = 7;
        };
      };
    };
}
