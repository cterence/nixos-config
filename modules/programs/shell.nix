{ inputs, ... }:
{
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.shell.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
    {
      imports = [
        inputs.nix-index-database.homeModules.default
        inputs.direnv-instant.homeModules.default
      ];

      home.file.".p10k.zsh".source = "${inputs.dotfiles}/.p10k.zsh";

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
            kdebug = "kubectl run shell-terence-$(uuidgen | tr -d '-' | tr '[:upper:]' '[:lower:]' | head -c 8) --image=ghcr.io/cterence/pkgx-bash -i --tty --rm";
            kns = "kubectl ns";
            ll = "ls -l";
            nfu = "nix flake update";
            nhup = "cd ${
              if isDarwin then "~/nix-darwin" else "~/nixos"
            } && git pull --rebase --autostash && nhs && cd -";
            nhs = "nh ${
              if isDarwin then "darwin switch ~/nix-darwin" else "os switch ~/nixos"
            } -- --show-trace";
            nixup = "cd ${if isDarwin then "~/nix-darwin" else "~/nixos"} && git pull --rebase --autostash && ${
              if isDarwin then
                "sudo darwin-rebuild switch --flake ~/nix-darwin"
              else
                "nixos-rebuild switch --sudo --flake ~/nixos"
            } && cd -";
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

            ai () {
              if [[ $# -eq 0 ]]; then
                echo "usage: ai <question>" >&2
                return 1
              fi
              local question="$*"
              local os arch shell pkg tools ctx
              os=$(uname -s)
              arch=$(uname -m)
              shell=$SHELL
              pkg=$(
                if command -v nix &>/dev/null; then echo "nix"
                elif command -v brew &>/dev/null; then echo "brew"
                elif command -v apt &>/dev/null; then echo "apt"
                elif command -v dnf &>/dev/null; then echo "dnf"
                fi
              )
              tools=$(
                local available=()
                for t in kubectl docker git gh helm terraform jq curl fzf rg fd python3 node go cargo npm brew nix nixos-rebuild darwin-rebuild; do
                  command -v $t &>/dev/null && available+=$t
                done
                echo ''${available:--none-}
              )
              ctx="OS: ''${os} (''${arch}) | Shell: ''${shell} | Pkg manager: ''${pkg:-unknown} | CWD: ''${PWD} | Available tools: ''${tools}"
              local response
              response=$(curl -s https://api.mistral.ai/v1/chat/completions \
                -H "Authorization: Bearer ''${MISTRAL_API_KEY}" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                  --arg ctx "$ctx" \
                  --arg q "$question" '{
                  model: "zai-glm-5-2",
                  reasoning_effort: "low",
                  messages: [
                    {role: "system", content: ("You translate natural-language requests into a single shell command. Output ONLY the command, no explanation, no markdown fences, no backticks. Use the system context to choose correct syntax and tools. If you cannot produce a command, respond with a line starting with # explaining why. " + $ctx)},
                    {role: "user", content: $q}
                  ]
                }')")
              local command
              command=$(echo "$response" | tr '[:cntrl:]' ' ' | sed 's/\\\././g' | jq -r '
                (.choices[0].message.content // "") |
                if type == "array" then [.[] | select(.type == "text") | .text] | last // "" else . end
              ' 2>/dev/null)
              if [[ -z "$command" ]]; then
                echo "ai: no response from API" >&2
                echo "$response" | tr '[:cntrl:]' ' ' | sed 's/\\\././g' | jq -r '.error.message // .' >&2
                return 1
              fi
              if [[ "$command" == \#* ]]; then
                echo "$command" >&2
                return 0
              fi
              print -z "$command"
            }
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
          enableZshIntegration = false;
          nix-direnv.enable = true;
        };

        direnv-instant = {
          enable = true;
          enableZshIntegration = true;
        };

        bash = {
          enable = true;
          enableCompletion = true;
        };
      };
    };
}
