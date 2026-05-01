{
  flake.aspects =
    { aspects, ... }:
    {
      system-personal = {
        includes = with aspects; [
          homelab-client-cert
          games
        ];
      };
    };
}
