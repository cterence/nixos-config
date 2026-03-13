{ self, ... }:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework13";
  flake.modules.nixos.framework13 = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      systemd-boot
      fingerprint
      terence-desktop
    ];
    networking.hostName = "framework13";

    system.stateVersion = "25.11";
  };
}
