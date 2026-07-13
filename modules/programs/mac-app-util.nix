{ inputs, ... }:
{
  flake-file.inputs = {
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.mac-app-util.darwin = {
    imports = [
      inputs.mac-app-util.darwinModules.default
    ];
  };
}
