{ config, pkgs, ... }:
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        k = "kubectl";
        kctx = "kubectl ctx";
        kdebug = ''kubectl run shell-terence-$(cat /proc/sys/kernel/random/uuid | sed "s/[ - ] // g " | head -c 8; echo;) --image=ghcr.io/cterence/pkgx-bash -i --tty --rm'';
        kns = "kubectl ns";
        hdu = "helm dep update";
        ll = "ls -l";
        nfu = "nix flake update";
        nhup = "cd ~/nixos && git pull --rebase --autostash && nh os switch ~/nixos -- --show-trace && cd -";
        nixup = "cd ~/nixos && git pull --rebase --autostash && nixos-rebuild switch --use-remote-sudo --flake ~/nixos && cd -";
        src = "source $HOME/.zshrc";
        tf = "terraform fmt && terraform";
        tg = "terragrunt hclfmt && terragrunt";
        watch = "watch ";
      };

      localVariables = {
        PATH = "$PATH:$HOME/.local/bin:$HOME/.krew/bin";
      };

      sessionVariables = {
        AWS_PAGER = "jq";
        BINDIR = "$HOME/.local/bin";
        EDITOR = "nano";
        TG_PROVIDER_CACHE = "1";
        FZF_BASE = "$HOME/.nix-profile/bin";
        NIXD_FLAGS = "-log=error";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "docker"
          "fzf"
          "git"
          "kubectl"
          "terraform"
          "aws"
          "direnv"
          "z"
        ];
      };

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      initContent = ''
        source ~/.p10k.zsh

        nb () {
          nix-build -E "(import <nixpkgs> { }).callPackage ./$1 { }"
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
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
    };
    z-lua = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
