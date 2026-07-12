{ inputs, self, ... }:
let
  hostname = "homelab2";
in
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" hostname;

  flake.aspects =
    { aspects, ... }:
    {
      ${hostname} = {
        includes = with aspects; [
          system-server
          systemd-boot
          k0s
          comin
          terence-server
        ];

        nixos = { config, ... }: {
          networking.hostName = hostname;

          services.k0s = {
            enable = true;
            role = "controller+worker";
            controller.isLeader = true;
            spec = {
              api = {
                address = "192.168.1.54";
                sans = [
                  "192.168.1.54"
                ];
              };
              network.kuberouter.metricsPort = 8081;
              storage.etcd.peerAddress = "192.168.1.54";
            };
          };

          sops = {
            templates."openbao-keys.yaml".content = ''
              unseal-key-1: "${config.sops.placeholder.unseal-key-1}"
              unseal-key-2: "${config.sops.placeholder.unseal-key-2}"
              unseal-key-3: "${config.sops.placeholder.unseal-key-3}"
            '';
            secrets = {
              unseal-key-1 = {
                sopsFile = "${inputs.secrets}/openbao.yaml";
              };
              unseal-key-2 = {
                sopsFile = "${inputs.secrets}/openbao.yaml";
              };
              unseal-key-3 = {
                sopsFile = "${inputs.secrets}/openbao.yaml";
              };
            };
          };

          system.stateVersion = "25.11";
        };
      };
    };
}
