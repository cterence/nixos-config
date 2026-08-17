{ inputs, ... }:
{
  flake-file.inputs = {
    # Parent of ff36900ebeebee157762ef16afe72aa3f3bd140d ("discord: don't strip
    # upstream binaries on darwin") which corrupts the macOS app.
    # https://github.com/NixOS/nixpkgs/issues/544338
    nixpkgs-discord-darwin.url = "github:nixos/nixpkgs/ffa10e26ae11d676b2db836259889f1f571cb14f";
  };

  # On darwin, build discord from the pinned (pre-regression) nixpkgs but feed it
  # the latest upstream source version from the main nixpkgs sources.json. Applied
  # only in the darwin aspect of desktop-apps, so no platform guard needed here.
  flake.overlays.discord-pinned = _final: _prev: {
    discord =
      let
        pinnedPkgs = import inputs.nixpkgs-discord-darwin {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        sources = pinnedPkgs.lib.importJSON "${inputs.nixpkgs}/pkgs/applications/networking/instant-messengers/discord/sources.json";
        latestSource = sources."osx-stable";
      in
      pinnedPkgs.discord.override {
        source = latestSource;
      };
  };
}
