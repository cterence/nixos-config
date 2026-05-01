{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  flake.aspects.vibe.homeManager =
    { pkgs, config, ... }:
    {
      home = {
        file = {
          vibe-config = {
            source = "${inputs.dotfiles}/vibe/config.toml";
            target = "${config.home.homeDirectory}/.vibe/config.toml";
          };
        };
        packages = [
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mistral-vibe
        ];
      };
    };
}
