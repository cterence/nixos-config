{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  flake.aspects.vibe.homeManager =
    let
      flattenSkills =
        source: prefix:
        let
          entries = builtins.readDir source;
          isDir = name: entries.${name} == "directory" || entries.${name} == "symlink";
          skillNames = builtins.filter isDir (builtins.attrNames entries);
        in
        builtins.listToAttrs (
          map (name: {
            name = "${prefix}-${name}";
            value = {
              target = ".vibe/skills/${name}";
              source = "${source}/${name}";
            };
          }) skillNames
        );
    in
    { pkgs, lib, ... }:
    {
      home = {
        activation.vibe-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          LIVE="$HOME/.vibe/config.toml"
          REPO="$HOME/${
            if pkgs.stdenv.hostPlatform.isDarwin then "nix-darwin" else "nixos-config"
          }/dotfiles/vibe/config.toml"

          if [ -f "$LIVE" ]; then
            # Vibe owns the live config; mirror its changes back into the repo
            # dotfile so the working tree tracks what vibe writes.
            mkdir -p "$(dirname "$REPO")"
            cat "$LIVE" > "$REPO"
          elif [ -f "${inputs.dotfiles}/vibe/config.toml" ]; then
            # Fresh install with no live config yet: seed from the built-in dotfile.
            mkdir -p "$(dirname "$LIVE")"
            cat "${inputs.dotfiles}/vibe/config.toml" > "$LIVE"
          fi
        '';

        packages = [
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mistral-vibe
        ];

        file = {
          vibe-karpathy-skills = {
            target = ".vibe/skills/karpathy";
            source = "${inputs.karpathy-skills}/skills/karpathy-guidelines";
          };
        }
        // flattenSkills "${inputs.caveman-skills}/skills" "caveman"
        // flattenSkills "${inputs.go-skills}" "go";
      };
    };
}
