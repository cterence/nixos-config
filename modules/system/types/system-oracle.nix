{
  flake.aspects =
    { aspects, ... }:
    {
      system-oracle.includes = with aspects; [
        system-cli
        settings-oracle
        disko
      ];
    };
}
