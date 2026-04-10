{
  self,
  ...
}:
{
  flake.modules.nixos.system-server = {
    imports = with self.modules.nixos; [
      system-cli
      networking
      settings-homelab
    ];
  };

  flake.modules.homeManager.system-server = {
    imports = with self.modules.homeManager; [
      system-cli
      kopia-sync
      tmux
    ];
  };
}
