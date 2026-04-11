{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
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
      };
      programs.opencode = {
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
    };
}
