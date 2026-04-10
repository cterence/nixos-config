{
  self,
  ...
}:
{
  flake.modules.nixos.system-default = {
    imports =
      with self.modules.nixos;
      [
        system-minimal
        niks3
        home-manager
        secrets
        qol
      ]
      ++ (with self.modules.generic; [
        pkgs-by-name
      ]);
  };

  flake.modules.homeManager.system-default = {
    imports = with self.modules.homeManager; [
      system-minimal
      niks3
      secrets
    ];
  };
}
