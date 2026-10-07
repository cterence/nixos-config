{
  self,
  ...
}:
{
  flake.aspects =
    { aspects, ... }:
    {
      system-server = {
        includes = with aspects; [
          system-cli
          catbox
          clowder
          networking
          tmux
          settings-homelab
        ];

        homeManager = {
          imports = with self.modules.homeManager; [
            kopia-sync
          ];
        };
      };
    };
}
