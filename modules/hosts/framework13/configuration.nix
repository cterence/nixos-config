{ self, ... }:
let
  hostname = "framework13";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;

  flake.aspects =
    { aspects, ... }:
    {
      ${hostname} = {
        includes = with aspects; [
          system-desktop
          system-personal
          systemd-boot
          fingerprint
          comin
          terence-desktop
        ];

        nixos = {
          networking.hostName = hostname;
          system.stateVersion = "25.11";
        };
      };
    };
}
