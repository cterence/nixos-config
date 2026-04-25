{ inputs, ... }:
{
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.shell =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      home.file.".p10k.zsh".source = "${inputs.dotfiles}/.p10k.zsh";

      sops.secrets = {
        cachix-auth-token = {
          sopsFile = "${inputs.secrets}/cachix.yaml";
        };
      };

      programs = {
        zsh = {
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

          shellAliases = {
            hdu = "helm dep update";
            k = "kubectl";
            kctx = "kubectl ctx";
            kdebug = ''kubectl run shell-terence-$(cat /proc/sys/kernel/random/uuid | sed "s/[ - ] // g " | head -c 8; echo;) --image=ghcr.io/cterence/pkgx-bash -i --tty --rm'';
            kns = "kubectl ns";
            ll = "ls -l";
            nfu = "nix flake update";
            nhup = "cd ~/nixos && git pull --rebase --autostash && nh os switch ~/nixos -- --show-trace && cd -";
            nhs = "nh os switch ~/nixos -- --show-trace";
            nixup = "cd ~/nixos && git pull --rebase --autostash && nixos-rebuild switch --sudo --flake ~/nixos && cd -";
            src = "source $HOME/.zshrc";
            tf = "terraform";
            tg = "terragrunt";
            watch = "watch ";
          };

          localVariables = {
            PATH = "$PATH:$HOME/.krew/bin";
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

            export CACHIX_AUTH_TOKEN=$(cat ${config.sops.secrets.cachix-auth-token.path})
          '';
        };

        z-lua = {
          enable = true;
          enableZshIntegration = true;
        };

        fzf = {
          enable = true;
          enableZshIntegration = true;
        };

        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        bash = {
          enable = true;
          enableCompletion = true;
        };
      };
    };
}
