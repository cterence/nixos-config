{
  flake.modules.homeManager.development = {
    programs = {
      go.enable = true;
      vscode = {
        enable = true;
        # package = pkgs.vscode.overrideAttrs (previousAttrs: {
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
    };
  };
}
