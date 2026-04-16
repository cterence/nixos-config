{ self, ... }:
let
  hostname = "t14s";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;

  flake.modules.nixos.t14s = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      system-laptop
      systemd-boot
      fingerprint
      terence-desktop
      comin
    ];
    networking.hostName = hostname;

    system.stateVersion = "25.11";
  };
}
