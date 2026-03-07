{
  inputs,
  ...
}:
{
  # Needed to avoid recursion / module redefinition errors
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
  ];
}
