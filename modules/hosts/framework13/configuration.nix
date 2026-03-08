{ inputs, ... }:
{
  flake.modules.nixos.framework13 = {
    imports =
      with inputs.self.modules.nixos;
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
    networking.hostName = "framework13";

    system.stateVersion = "25.11";

    services.fprintd.enable = true;
    security.pam.services = {
      login.fprintAuth = false;
      sddm.fprintAuth = true;
    };
  };
}
