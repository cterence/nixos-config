{
  flake.modules.nixos.qol = {
    # Allow /bin/bash to be used as a shell for scripts
    # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673/63
    services.envfs.enable = true;
    programs.nix-ld.enable = true;
  };
}
