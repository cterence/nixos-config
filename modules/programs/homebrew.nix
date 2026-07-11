{ inputs, ... }: {
  flake-file.inputs = {
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  flake.aspects.homebrew.darwin = {
    imports = [
      inputs.nix-homebrew.darwinModules.nix-homebrew
    ];

    nix-homebrew = {
      # Install Homebrew under the default prefix
      enable = true;

      # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
      enableRosetta = true;

      # User owning the Homebrew prefix
      user = "terence";

      # Optional: Enable fully-declarative tap management
      #
      # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
      mutableTaps = false;

      # Optional: Declarative Homebrew tap trust entries.
      #
      # Note: The trust entries are _not_ removed if you remove them from those lists!
      # Use the `brew untrust` command to remove a trust entry.
      trust = {
        formulae = [ ];
        casks = [
        ];
        commands = [ ];
        taps = [
        ];
      };
    };

    homebrew = {
      enable = true;
      onActivation.cleanup = "zap";
      casks = [
        "markedit"
        "nextcloud"
        "scroll-reverser"
        "stats"
        "steam"
      ];
      brews = [
      ];
    };
  };
}
