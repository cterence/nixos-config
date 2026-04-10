{ self, ... }:
{
  flake.modules.nixos.system-oracle = {
    imports = with self.modules.nixos; [
      system-cli
      settings-oracle
      disko
    ];
  };
}
