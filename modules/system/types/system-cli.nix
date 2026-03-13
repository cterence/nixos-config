{
  self,
  ...
}:
{
  flake.modules.nixos.system-cli = {
    imports = with self.modules.nixos; [
      system-default
      docker
      cli-tools
      tailscale
    ];
  };

  flake.modules.homeManager.system-cli = {
    imports = with self.modules.homeManager; [
      system-default
      cli-tools
      gpg
      shell
    ];
  };
}
