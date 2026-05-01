{ self, ... }:
let
  hostname = "free-oracle-arm-1";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "aarch64-linux" hostname;

  flake.aspects =
    { aspects, ... }:
    {
      ${hostname} = {
        includes = with aspects; [
          system-oracle
          systemd-boot
          terence-server
        ];
        nixos = {
          networking.hostName = hostname;
          system.stateVersion = "25.11";

          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
          ];
        };
      };
    };
}
