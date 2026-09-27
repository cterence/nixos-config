{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  flake.aspects.vibe.homeManager =
    let
      toHomeFile =
        skills:
        let
          entries = builtins.filter (s: builtins.elem "vibe" s.agents) skills;
          flatten =
            s:
            let
              dirs = builtins.readDir s.source;
              isDir = name: dirs.${name} == "directory" || dirs.${name} == "symlink";
              excluded = s.exclude or [ ];
              skillNames = builtins.filter (name: isDir name && !builtins.elem name excluded) (
                builtins.attrNames dirs
              );
            in
            builtins.listToAttrs (
              map (name: {
                name = "${s.name}-${name}";
                value = {
                  target = ".vibe/skills/${name}";
                  source = "${s.source}/${name}";
                };
              }) skillNames
            );
          mount = s: {
            "vibe-${s.name}" = {
              target = ".vibe/skills/${s.name}";
              inherit (s) source;
            };
          };
        in
        builtins.foldl' (acc: s: acc // (if s.flatten or false then flatten s else mount s)) { } entries;
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

          # Install the shared agent instructions (repo-owned, one-way copy).
          cat "${inputs.dotfiles}/AGENTS.md" > "$HOME/.vibe/AGENTS.md"
        '';

        packages = [
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mistral-vibe
        ];

        file = toHomeFile self.lib.skills;
      };
    };
}
