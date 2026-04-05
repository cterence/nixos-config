{ inputs, ... }:
{
  flake.modules.homeManager.development =
    { config, ... }:
    {
      programs = {
        go.enable = true;
        vscode = {
          enable = true;
          # package = pkgs.vscode.overrideAttrs (previousAttrs= {
          #   postFixup = previousAttrs.postFixup + ''
          #     sed -i -e "s|StartupWMClass=.*|StartupWMClass=code-url-handler|" $out/share/applications/code-url-handler.desktop
          #   '';
          # });
          profiles.default.userSettings = {
            "workbench.iconTheme" = "material-icon-theme";
            "terminal.integrated.fontFamily" =
              "'JetBrainsMono Nerd Font','JetBrainsMono Nerd Font Mono','MesloLGS NF','MesloLGS Nerd Font'";
            "editor.fontFamily" =
              "'JetBrainsMono Nerd Font','JetBrains Mono','MesloLGS Nerd Font','Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
            "editor.tabSize" = 2;
            "files.insertFinalNewline" = true;
            "files.trimFinalNewlines" = true;
            "[terraform]" = {
              "editor.defaultFormatter" = "hashicorp.terraform";
            };
            "[javascript]" = {
              "editor.defaultFormatter" = "vscode.typescript-language-features";
            };
            "editor.fontLigatures" = true;
            "editor.wordWrap" = "on";
            "diffEditor.ignoreTrimWhitespace" = false;
            "workbench.editorAssociations" = {
              "*.pdf" = "latex-workshop-pdf-hook";
              "git-rebase-todo" = "gitlens.rebase";
            };
            "redhat.telemetry.enabled" = false;
            "[yaml]" = {
              "editor.defaultFormatter" = "redhat.vscode-yaml";
            };
            "workbench.sideBar.location" = "right";
            "go.formatTool" = "gofmt";
            "[json]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "workbench.colorTheme" = "The Best Theme";
            "aws.telemetry" = false;
            "go.toolsManagement.autoUpdate" = true;
            "github.copilot.enable" = {
              "*" = false;
              "plaintext" = false;
              "markdown" = false;
              "scminput" = false;
            };
            "launch" = {
              "configurations" = [ ];
              "compounds" = [ ];
            };
            "editor.unicodeHighlight.nonBasicASCII" = false;
            "[markdown]" = {
              "editor.formatOnSave" = true;
              "editor.defaultFormatter" = "darkriszty.markdown-table-prettify";
            };
            "nix.enableLanguageServer" = true;
            "nix.serverSettings" = {
              "nixd" = {
                "formatting" = {
                  "command" = [
                    "nixfmt"
                  ];
                };
                "options" = {
                  "nixos" = {
                    "expr" = "(builtins.getFlake \"${"env:HOME"}/nixos\").nixosConfigurations.${"env:HOST"}.options";
                  };
                };
                "nixpkgs" = {
                  "expr" = "import <nixpkgs> { }";
                };
              };
            };
            "github.copilot.editor.enableAutoCompletions" = false;
            "files.trimTrailingWhitespace" = true;
            "settingsSync.ignoredExtensions" = [
              "jnoortheen.nix-ide"
              "mistralai.mistral-code"
            ];
            "settingsSync.ignoredSettings" = [
              "nix.serverSettings"
            ];
            "nix.serverPath" = "nixd";
            "[nix]" = {
              "editor.defaultFormatter" = "jnoortheen.nix-ide";
            };
            "nix.formatterPath" = "nixfmt";
            "yaml.extension.recommendations" = false;
            "yaml.schemas" = { };
            "editor.formatOnSave" = true;
            "[helm]" = {
              "editor.defaultFormatter" = "redhat.vscode-yaml";
            };
            "todohighlight.isEnable" = true;
            "docker.extension.enableComposeLanguageServer" = false;
            "[dockercompose]" = {
              "editor.insertSpaces" = true;
              "editor.tabSize" = 2;
              "editor.autoIndent" = "advanced";
              "editor.quickSuggestions" = {
                "other" = true;
                "comments" = false;
                "strings" = true;
              };
              "editor.defaultFormatter" = "redhat.vscode-yaml";
            };
            "[github-actions-workflow]" = {
              "editor.defaultFormatter" = "redhat.vscode-yaml";
            };
            "direnv.restart.automatic" = true;
          };
        };

        opencode = {
          enable = true;
          settings = {
            enabled_providers = [ "mistral" ];
            provider = {
              mistral = {
                options = {
                  apiKey = "{file:${config.sops.secrets.mistral-api-key.path}}";
                };
              };
            };
            mcp = {
              grafana = {
                type = "remote";
                url = "https://gmcp.terence.cloud/sse";
                oauth = false;
                headers = {
                  Authorization = "Basic {file:${config.sops.secrets.grafana-mcp-auth.path}}";
                };
              };
            };
            permission = {
              "*" = "allow";
              "bash" = {
                "*" = "allow";
                "touch *" = "ask";
                "mkdir *" = "ask";
                "rm *" = "ask";
                "cp *" = "ask";
                "mv *" = "ask";
                "dd *" = "ask";
                "sudo *" = "ask";
                "chmod *" = "ask";
                "chown *" = "ask";
                "curl *" = "ask";
                "wget *" = "ask";
                "npm install *" = "ask";
                "pip install *" = "ask";
                "git push" = "ask";
                "git reset --hard *" = "ask";
                "git clean *" = "ask";
                "reboot" = "ask";
                "shutdown" = "ask";
                "kill *" = "ask";
                "killall *" = "ask";
                "docker *" = "ask";
                "mkfs *" = "ask";
                "fdisk *" = "ask";
                "parted *" = "ask";
                "format *" = "ask";
                "git branch -d *" = "ask";
                "git branch -D *" = "ask";
                "git rebase *" = "ask";
                "npm run publish" = "ask";
                "brew install *" = "ask";
                "brew upgrade *" = "ask";
                "ssh *" = "ask";
                "scp *" = "ask";
                "rsync *" = "ask";
                "nix *" = "ask";
                "nixos-rebuild *" = "ask";
              };
              "doom_loop" = "ask";
              "external_directory" = "ask";
            };
          };
        };

        zsh.initContent = ''
          export MISTRAL_API_KEY="$(cat ${config.sops.secrets.mistral-api-key.path})"
        '';
      };

      sops = {
        secrets = {
          openbao-root-token = {
            sopsFile = "${inputs.secrets}/openbao.yaml";
            key = "root-token";
            path = config.home.homeDirectory + "/.vault-token";
          };
          mistral-api-key = {
            sopsFile = "${inputs.secrets}/mistral-api-key.yaml";
          };
          grafana-mcp-auth = {
            sopsFile = "${inputs.secrets}/grafana-mcp-auth.yaml";
          };
        };
      };
    };
}
