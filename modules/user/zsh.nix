{ config, pkgs, ... }:
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
        nhup = "cd ~/nixos && git pull --rebase --autostash && nh os switch ~/nixos && cd -";
        nixup = "cd ~/nixos && git pull --rebase --autostash && nixos-rebuild switch --use-remote-sudo --flake ~/nixos && cd -";
        kdebug = ''kubectl run shell-terence-$(cat /proc/sys/kernel/random/uuid | sed "s/[ - ] // g " | head -c 8; echo;) --image=stangirard/alpine-powerhouse -i --tty --rm'';
        tf = "terraform fmt && terraform";
        tg = "terragrunt hclfmt && terragrunt";
        k = "kubectl";
        kctx = "kubectl ctx";
        kns = "kubectl ns";
        watch = "watch ";
        ssh = "kitty +kitten ssh";
        src = "source $HOME/.zshrc";
      };

      localVariables = {
        PATH = "$PATH:$HOME/.local/bin:$HOME/.krew/bin";
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

      initExtra = ''
        source ~/.p10k.zsh
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
