{ self, ... }:
let
  hostname = "free-oracle-amd-2";
in
{
  # How to be able to nixos-anywhere kexec without oomkill:
  # ssh opc@_ip_
  # sudo -i
  # systemctl stop pmcd pmlogger pmproxy pmie
  # pkill -9 pmda
  # systemctl stop oracle-cloud-agent
  # systemctl stop oracle-cloud-agent-updater
  # pkill -u ocarun
  # systemctl stop firewalld
  # systemctl stop tuned
  # sync; echo 3 > /proc/sys/vm/drop_caches
  # echo 1 > /proc/sys/vm/compact_memory

  # Then run:
  # nixos-anywhere --flake .#free-oracle-amd-2 --no-disko-deps opc@_ip_

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;

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

          # MANDATORY: Add key to root so nixos-anywhere can finish the install
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
          ];

          zramSwap = {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 150; # 1GB RAM -> 1.5GB zram
            priority = 10;
          };
        };
      };
    };
}
