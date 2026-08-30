{ self, ... }:
let
  hostname = "stronghold";
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
          comin
          terence-desktop
        ];

        nixos = {
          home-manager.users.terence.imports = with self.modules.homeManager; [
            kopia-sync
          ];

          networking = {
            hostName = hostname;
            hosts = {
              "100.114.190.13" = [ "versity-gw-storage-pool.versity-gw" ];
            };
          };
          system.stateVersion = "25.11";
        };
      };
    };
}
