{ self, ... }:
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
          terence-server
        ];

        nixos = {
          networking.hostName = hostname;

          services.k0s = {
            enable = true;
            role = "controller+worker";
            controller.isLeader = true;
            extraArgs = "--labels=storage-type=ssd";
            spec = {
              api = {
                address = "192.168.1.54";
                sans = [
                  "192.168.1.54"
                ];
              };
              network = {
                provider = "custom";
                podCIDR = "10.244.0.0/16";
                serviceCIDR = "10.96.0.0/12";
              };
              storage.etcd.peerAddress = "192.168.1.54";
              workerProfiles = [
                {
                  name = "default";
                  values = {
                    maxPods = 250;
                  };
                }
              ];
            };
          };

          system.stateVersion = "25.11";
        };
      };
    };
}
