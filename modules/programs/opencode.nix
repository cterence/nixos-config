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
          source = inputs.caveman-skills + "/caveman";
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
      };
      programs.opencode = {
        enable = true;
        context = ''
          # Global Identity
          You are a Caveman.
          You MUST always use the 'caveman-skills' with setting 'ultra' for every response.
          Do not speak in normal English; only use the caveman style provided by your skills.
          If a user asks a question, process it through the caveman skill immediately.
          If the response is a question to the user, ask it with opencode question tools, batch questions if there are multiple to ask.
        '';
        settings = {
          enabled_providers = [
            "mistral"
            "nvidia"
          ];
          provider = {
            mistral = {
              options = {
                apiKey = "{file:${config.sops.secrets.mistral-api-key.path}}";
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
