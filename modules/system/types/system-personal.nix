{
  self,
  ...
}:
{
  flake.modules.nixos.system-personal = {
    imports = with self.modules.nixos; [
      games
      homelab-client-cert
    ];
  };

  flake.modules.homeManager.system-personal = {
    imports = with self.modules.homeManager; [
      homelab-client-cert
    ];
  };
}
