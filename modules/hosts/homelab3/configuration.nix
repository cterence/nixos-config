{ inputs, self, ... }:
{
  flake.modules.nixos.homelab3 =
    { config, ... }:
    {
      imports =
        with self.modules.nixos;
        [
          common-settings
          homelab-settings
          common-services
          cli-tools
          docker
          home-manager
          homelab-client-cert
          k0s
          systemd-boot
          terence
          tailscale
        ]
        ++ [
          inputs.sops-nix.nixosModules.sops
          inputs.k0s.nixosModules.default
        ];
      networking.hostName = "homelab3";

      sops.secrets = {
        "k0s-token" = {
          path = "/etc/k0s/k0stoken";
          mode = "0440";
          sopsFile = "${inputs.secrets}/k0s-token.yaml";
          group = config.users.groups.keys.name;
        };
      };

      services.k0s = {
        enable = true;
        role = "worker";
        spec = {
          api = {
            address = "192.168.1.54";
            sans = [
              "192.168.1.54"
            ];
          };
        };
      };

      system.stateVersion = "25.11";
    };
}
