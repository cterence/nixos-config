{
  flake.modules.nixos.common-services = {
    networking.networkmanager.enable = true;

    services = {
      openssh.enable = true;

      # Allow /bin/bash to be used as a shell for scripts
      # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673/63
      envfs.enable = true;
      fwupd.enable = true;
    };

    systemd = {
      services = {
        nix-daemon.serviceConfig.EnvironmentFile = "/etc/nixos/nix-daemon-environment";
      };
    };
  };
}
