{
  self,
  ...
}:
{
  flake.modules.nixos.system-server = {
    imports = with self.modules.nixos; [
      system-cli
      homelab-settings
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
