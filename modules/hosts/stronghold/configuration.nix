{ self, ... }:
let
  hostname = "stronghold";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;
  flake.modules.nixos.stronghold = {
    imports = with self.modules.nixos; [
      system-desktop
      system-personal
      systemd-boot
      fingerprint
      terence-desktop
    ];

    home-manager.users.terence.imports = with self.modules.homeManager; [
      kopia-sync
    ];

    networking.hostName = hostname;

    system.stateVersion = "25.11";
  };
}
