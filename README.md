# nixos-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

A nix flake I use to configure my computers. Dendritic structure heavily inspired by [Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts).

## Tips

- When a package fails to build, get the last successful build's revision and create a new nixpkgs input to pin the broken package's version:

  ```shell
  nix shell nixpkgs#hydra-check -c hydra-check --channel unstable <pkg>
  ```
