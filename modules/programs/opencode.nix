{ self, ... }:

{
  flake.aspects.opencode.homeManager =
    let
      toHomeFile =
        skills:
        builtins.listToAttrs (
          map (s: {
            inherit (s) name;
            value = {
              inherit (s) source;
              target = ".config/opencode/skills/${s.dir or s.name}";
            };
          }) (builtins.filter (s: builtins.elem "opencode" s.agents) skills)
        );
    in
    { config, ... }:
    {
      home.file = toHomeFile self.lib.skills // {
        agents-md = {
          target = ".config/opencode/AGENTS.md";
          source = self.lib.agentsMd;
        };
      };
      programs.opencode = {
        enable = true;
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
              url = "https://gmcp.terence.cloud/mcp";
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
