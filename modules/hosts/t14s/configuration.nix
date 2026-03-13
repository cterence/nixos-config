{ inputs, ... }:
{
  flake.modules.nixos.t14s = {
    imports =
      with inputs.self.modules.nixos;
      [
        audio
        bluetooth
        common-settings
        common-services
        cli-tools
        docker
        fingerprint
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
    networking.hostName = "t14s";

    system.stateVersion = "25.11";
  };
}
