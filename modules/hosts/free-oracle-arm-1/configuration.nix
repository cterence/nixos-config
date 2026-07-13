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
        };
      };
    };
}
