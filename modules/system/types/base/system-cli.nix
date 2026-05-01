{
  flake.aspects =
    { aspects, ... }:
    {
      system-cli = {
        includes = with aspects; [
          system-default
          docker
          cli-tools
          tailscale
          gpg
          shell
        ];
      };
    };
}
