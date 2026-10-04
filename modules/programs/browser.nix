{
  self,
  ...
}:
{
  flake.aspects.browser = {
    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      {
        programs = {
          firefox = {
            enable = true;
            # The wrapped Firefox renames the real binary to .firefox-old, so
            # macOS 27 cannot resolve it as frontmost (breaks window managers).
            package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin pkgs.firefox-unwrapped;
          };
          chromium.enable = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) true;
        };
      };

    darwin =
      {
        config,
        ...
      }:
      {
        # firefox-unwrapped ignores home-manager's configPath, so replicate the
        # profile-dir env the nixpkgs wrapper used to set.
        launchd.user.agents.mozilla-env.serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            "/bin/launchctl setenv MOZ_APP_DATA '${
              config.users.users.${self.lib.username}.home
            }/.config/mozilla/firefox'; /bin/launchctl setenv MOZ_LEGACY_PROFILES 1; /bin/launchctl setenv MOZ_ALLOW_DOWNGRADE 1"
          ];
          RunAtLoad = true;
        };
      };
  };
}
