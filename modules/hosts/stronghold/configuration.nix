{
  inputs,
  lib,
  self,
  ...
}:
let
  hostname = "stronghold";
in
{
  flake-file.inputs.nixpkgs-kernel.url = "github:nixos/nixpkgs/9fbb54b33e91ee4ca368e35a78e0613c720600b3";

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
          boot.kernelPackages = lib.mkForce inputs.nixpkgs-kernel.legacyPackages.x86_64-linux.linuxPackages_latest;

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
