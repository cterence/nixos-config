{ self, ... }:
let
  hostname = "framework13";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;
  flake.modules.nixos.framework13 = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      system-laptop
      systemd-boot
      fingerprint
      terence-desktop
    ];
    networking.hostName = hostname;

    system.stateVersion = "25.11";
  };
}
