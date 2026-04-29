{
  inputs,
  ...
}:
{
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      flake-aspects.url = "github:vic/flake-aspects";
    };
    outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
    '';
  };

  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.default
    inputs.flake-aspects.flakeModule
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
