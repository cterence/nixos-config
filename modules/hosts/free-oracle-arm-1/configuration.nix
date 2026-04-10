{ self, ... }:
let
  hostname = "free-oracle-arm-1";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "aarch64-linux" hostname;
  flake.modules.nixos.${hostname} = {
    imports = with self.modules.nixos; [
      system-oracle
      systemd-boot
    ];

    networking.hostName = hostname;
    system.stateVersion = "25.11";

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
    ];
  };
}
