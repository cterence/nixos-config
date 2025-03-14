{ pkgs, ... }:
{
  programs.zsh.initExtra = ''
    if [ -z "$TMUX" ]; then
        ${pkgs.tmux}/bin/tmux attach-session -t default || ${pkgs.tmux}/bin/tmux new-session -s default
    fi
  '';

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
    '';
  };
}
