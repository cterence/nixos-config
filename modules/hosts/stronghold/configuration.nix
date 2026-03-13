{ self, ... }:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "stronghold";
  flake.modules.nixos.stronghold = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      systemd-boot
      fingerprint
      terence-desktop
    ];
    networking.hostName = "stronghold";

    system.stateVersion = "25.11";
  };
}
