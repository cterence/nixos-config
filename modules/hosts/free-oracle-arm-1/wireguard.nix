{ inputs, ... }:
let
  hostname = "free-oracle-arm-1";
in
{
  flake.modules.nixos.${hostname} =
    { config, ... }:
    {
      sops = {
        secrets = {
          "wireguard-${hostname}" = {
            sopsFile = "${inputs.secrets}/wireguard.yaml";
            key = hostname;
          };
        };
      };

      networking = {
        firewall.allowedUDPPorts = [
          51413
          51820
        ];
        nat = {
          enable = true;
          enableIPv6 = false;
          externalInterface = "enp0s6";
          internalInterfaces = [ "wg0" ];
          forwardPorts = [
            {
              destination = "192.168.2.2:51413";
              proto = "tcp";
              sourcePort = 51413;
            }
            {
              destination = "192.168.2.2:51413";
              proto = "udp";
              sourcePort = 51413;
            }
          ];
        };
        wg-quick.interfaces = {
          wg0 = {
            address = [
              "192.168.2.1/24"
            ];
            mtu = 1420;
            listenPort = 51820;
            privateKeyFile = config.sops.secrets."wireguard-${hostname}".path;
            peers = [
              {
                publicKey = "toMF/CXlP9L+dEvl5Q+aqNZLqeH1Mpi5o+rwaheHWBc=";
                allowedIPs = [
                  "192.168.2.2/32"
                ];
              }
            ];
          };
        };
      };
    };
}
