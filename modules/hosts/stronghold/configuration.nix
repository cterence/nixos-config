{ inputs, self, ... }:
{
  flake.modules.nixos.stronghold = {
    imports =
      with self.modules.nixos;
      [
        audio
        bluetooth
        common-settings
        common-services
        cli-tools
        docker
        games
        home-manager
        homelab-client-cert
        kde
        printing
        systemd-boot
        terence
        tailscale
      ]
      ++ [
        inputs.sops-nix.nixosModules.sops
      ];
    networking.hostName = "stronghold";

    system.stateVersion = "25.11";
  };
}
