{ inputs, self, ... }:
let
  hostname = "homelab3";
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
          development
          terence-server
        ];

        nixos =
          { config, ... }:
          {
            networking.hostName = hostname;

            sops.secrets = {
              k0s-token = {
                path = "/etc/k0s/k0stoken";
                mode = "0440";
                sopsFile = "${inputs.secrets}/k0s-token.yaml";
                group = config.users.groups.keys.name;
              };
            };

            services = {
              k0s = {
                enable = true;
                role = "worker";
                extraArgs = "--labels=storage-type=ssd";
                spec = {
                  api = {
                    address = "192.168.1.54";
                    sans = [
                      "192.168.1.54"
                    ];
                  };
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
              nfs.server = {
                enable = true;
                exports = ''
                  /export                 192.168.1.54/32(rw,fsid=0,no_subtree_check,all_squash,anonuid=1000,anongid=100)
                  /export/mx500-homelab3  192.168.1.54/32(rw,nohide,fsid=1,no_subtree_check,all_squash,anonuid=1000,anongid=100)
                  /export/storage-pool    192.168.1.0/24(rw,nohide,fsid=2,no_subtree_check,no_root_squash,no_all_squash)
                '';
              };
            };

            systemd.services.nfs-server = {
              after = [ "mnt-storage-pool.mount" ];
              wants = [ "mnt-storage-pool.mount" ];
            };

            system.stateVersion = "25.11";
          };
      };
    };
}
