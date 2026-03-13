{ self, ... }:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "t14s";

  flake.modules.nixos.t14s = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      systemd-boot
      fingerprint
      terence-desktop
    ];
    networking.hostName = "t14s";

    system.stateVersion = "25.11";
  };
}
