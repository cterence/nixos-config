{
  flake.aspects.tmux.homeManager =
    { lib, pkgs, ... }:
    {
      # before the p10k instant-prompt preamble (mkBefore = 500): leaking
      # output after it trips the instant-prompt warning
      programs.zsh.initContent = lib.mkOrder 100 ''
        if [[ -o interactive && -z "$TMUX" ]] && [[ -t 0 && -t 1 ]]; then
          exec ${pkgs.tmux}/bin/tmux new-session -A -s default
        fi
      '';

      programs.tmux = {
        enable = true;
        extraConfig = ''
          set -g mouse on
        '';
      };
    };
}
