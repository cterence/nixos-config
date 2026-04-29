{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  flake.modules.homeManager.vibe =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mistral-vibe
      ];
    };
}
