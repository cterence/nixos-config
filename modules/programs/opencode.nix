{ inputs, ... }:

{
  flake-file.inputs = {
    caveman-skills = {
      flake = false;
      url = "github:JuliusBrussee/caveman";
    };
    go-skills = {
      flake = false;
      url = "github:spf13/go-skills";
    };
    terraform-skills = {
      flake = false;
      url = "github:hashicorp/agent-skills";
    };
    gws-skills = {
      flake = false;
      url = "github:googleworkspace/cli";
    };
    karpathy-skills = {
      flake = false;
      url = "github:forrestchang/andrej-karpathy-skills";
    };
    paperasse-skills = {
      flake = false;
      url = "github:romainsimon/paperasse";
    };
  };

  flake.aspects.opencode.homeManager =
    { config, ... }:
    {
      home.file = {
        go-skills = {
          source = inputs.go-skills;
          target = ".config/opencode/skills/go-skills";
        };
        terraform-skills = {
          source = inputs.terraform-skills + "/terraform";
          target = ".config/opencode/skills/terraform-skills";
        };
        caveman-skills = {
          source = inputs.caveman-skills + "/skills";
          target = ".config/opencode/skills/caveman-skills";
        };
        gws-skills = {
          source = inputs.gws-skills + "/skills";
          target = ".config/opencode/skills/gws-skills";
        };
        karpathy-skills = {
          source = inputs.karpathy-skills + "/skills/karpathy-guidelines";
          target = ".config/opencode/skills/karpathy-skills";
        };
        paperasse-syndic-skills = {
          source = inputs.paperasse-skills + "/syndic/";
          target = ".config/opencode/skills/paperasse-syndic";
        };
        paperasse-notaire-skills = {
          source = inputs.paperasse-skills + "/notaire/";
          target = ".config/opencode/skills/paperasse-notaire";
        };
        paperasse-comptable-skills = {
          source = inputs.paperasse-skills + "/comptable/";
          target = ".config/opencode/skills/paperasse-comptable";
        };
        paperasse-fiscaliste-skills = {
          source = inputs.paperasse-skills + "/fiscaliste/";
          target = ".config/opencode/skills/paperasse-fiscaliste";
        };
        paperasse-controleur-fiscal-skills = {
          source = inputs.paperasse-skills + "/controleur-fiscal/";
          target = ".config/opencode/skills/paperasse-controleur-fiscal";
        };
        paperasse-commissaire-aux-comptes-skills = {
          source = inputs.paperasse-skills + "/commissaire-aux-comptes/";
          target = ".config/opencode/skills/paperasse-commissaire-aux-comptes";
        };
      };
      programs.opencode = {
        enable = true;
        context = ''
          ## Caveman Style (embedded — ALWAYS active, no skill load needed)

          <IMPORTANT>
          Respond terse like smart caveman at **ultra** intensity every response. All technical substance stays; only fluff dies. Active every turn, no drift, no revert. Off only on "stop caveman" / "normal mode".

          Rules:
          - Drop articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course), hedging.
          - Fragments OK. Short synonyms (big not extensive, fix not "implement solution for"). Pattern: `[thing] [action] [reason]. [next step].`
          - Strip conjunctions when cause-then-effect unambiguous. One word when one word enough. State each fact once.
          - NO invented abbreviations (cfg/impl/req/res/fn/auth) — tokenizer splits same as full word, zero saving, worse clarity. Use full word.
          - NO causal arrows (X → Y) — own token, saves nothing.
          - No tool-call narration, no decorative tables/emoji, no dumping long raw error logs (quote shortest decisive line).
          - Preserve user's dominant language; compress style not language.
          - No self-reference, never announce the style. Standard acronyms OK (DB/API/HTTP). Technical terms, code, API/CLI names, commit keywords, exact error strings: verbatim, never touch.

          Auto-clarity — drop caveman (resume after) for: security warnings, irreversible-action confirmations, multi-step order-sensitive sequences, or when compression creates ambiguity.

          Boundaries: code/commits/PRs written normal. For other levels (lite/full/wenyan-*) or switching, load the full `caveman` skill.
          </IMPORTANT>
        '';
        settings = {
          model = "mistral-glm/zai-glm-5-2";
          enabled_providers = [
            "mistral"
            "mistral-glm"
            "nvidia"
          ];
          agent = {
            build = {
              temperature = 1.0;
            };
          };
          provider = {
            mistral = {
              options = {
                apiKey = "{file:${config.sops.secrets.mistral-api-key.path}}";
              };
            };
            mistral-glm = {
              name = "Mistral (GLM)";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = "https://api.mistral.ai/v1";
                apiKey = "{file:${config.sops.secrets.mistral-api-key.path}}";
              };
              models = {
                "zai-glm-5-2" = {
                  name = "GLM-5.2";
                  limit = {
                    context = 1000000;
                    output = 128000;
                  };
                  temperature = true;
                  options = {
                    reasoningEffort = "max";
                  };
                };
              };
            };
            nvidia = {
              options = {
                apiKey = "{file:${config.sops.secrets.nvidia-nim-api-key.path}}";
              };
            };
          };
          plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
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
            "skill" = {
              "*" = "allow";
            };
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
            "external_directory" = {
              "/tmp/**" = "allow";
            };
          };
        };
      };
    };
}
