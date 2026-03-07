{
  flake.modules.homeManager.shell =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;

        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        oh-my-zsh = {
          enable = true;
          plugins = [
            "direnv"
            "docker"
            "fzf"
            "git"
            "kubectl"
            "terraform"
            "z"
          ];
        };

        history.size = 10000;
        history.path = "${config.xdg.dataHome}/zsh/history";

        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];

        initContent = ''
          source ~/.p10k.zsh

          nb () {
            nix-build -E "(import <nixpkgs> { }).callPackage ./$1 { }"
          }

          nr () {
            nix run nixpkgs#"$@"
          }

          nru () {
            NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#"$@"
          }

          nrui () {
            NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix run --impure nixpkgs#"$@"
          }

          nfi () {
            for input in $@; do
            inputs="$inputs --update-input $input";
            done
            echo $inputs | xargs nix flake lock
            unset inputs
          }

          argodiff () {
            argocd app diff $1 --grpc-web --local-repo-root $(git rev-parse --show-toplevel) --local $PWD --loglevel warn
          }
        '';
      };

      programs.z-lua = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      programs.bash = {
        enable = true;
        enableCompletion = true;
      };
    };
}
