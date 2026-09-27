{ inputs, ... }:

{
  flake.lib.agentsMd = inputs.dotfiles + "/AGENTS.md";
}
