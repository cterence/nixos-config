{
  self,
  ...
}:
{
  flake.aspects =
    { aspects, ... }:
    {
      system-default = {
        includes = with aspects; [
          system-minimal
          niks3
          secrets
          home-manager
          qol
        ];

        nixos.imports = [
          self.modules.generic.pkgs-by-name
        ];
      };
    };
}
