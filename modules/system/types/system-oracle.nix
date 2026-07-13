{
  flake.aspects =
    { aspects, ... }:
    {
      system-oracle = {
        includes = with aspects; [
          system-cli
          settings-oracle
          disko
        ];

        # MANDATORY: Add key to root so nixos-anywhere can finish the install
        nixos = {
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITdJbmR8b5wJyc7UijPQGNfPBAkng6lChJsMDsOKZdf terence@t14s"
          ];
        };
      };
    };
}
