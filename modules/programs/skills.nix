{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    caveman-skills = {
      flake = false;
      url = "github:JuliusBrussee/caveman";
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
    ponytail-skills = {
      flake = false;
      url = "github:DietrichGebert/ponytail";
    };
    cc-skills-golang = {
      flake = false;
      url = "github:samber/cc-skills-golang";
    };
  };

  # Shared skill catalog consumed by the per-agent home.file builders in
  # opencode.nix and vibe.nix. Fields per entry:
  #   name    - unique id
  #   dir     - directory name used when mounted as a whole (defaults to name)
  #   source  - store path of the skill collection
  #   agents  - agents that should install this skill ("opencode" / "vibe")
  #   flatten - vibe expands the collection into one entry per sub-skill
  #   exclude - vibe-only: sub-skill names to skip when flattening
  flake.lib.skills = [
    {
      name = "caveman";
      dir = "caveman-skills";
      source = "${inputs.caveman-skills}/skills";
      agents = [
        "opencode"
        "vibe"
      ];
      flatten = true;
    }
    {
      name = "terraform";
      dir = "terraform-skills";
      source = "${inputs.terraform-skills}/terraform";
      agents = [ "opencode" ];
    }
    {
      name = "gws";
      dir = "gws-skills";
      source = "${inputs.gws-skills}/skills";
      agents = [ "opencode" ];
    }
    {
      name = "karpathy";
      dir = "karpathy-skills";
      source = "${inputs.karpathy-skills}/skills/karpathy-guidelines";
      agents = [
        "opencode"
        "vibe"
      ];
    }
    {
      name = "paperasse-syndic";
      source = "${inputs.paperasse-skills}/syndic/";
      agents = [ "opencode" ];
    }
    {
      name = "paperasse-notaire";
      source = "${inputs.paperasse-skills}/notaire/";
      agents = [ "opencode" ];
    }
    {
      name = "paperasse-comptable";
      source = "${inputs.paperasse-skills}/comptable/";
      agents = [ "opencode" ];
    }
    {
      name = "paperasse-fiscaliste";
      source = "${inputs.paperasse-skills}/fiscaliste/";
      agents = [ "opencode" ];
    }
    {
      name = "paperasse-controleur-fiscal";
      source = "${inputs.paperasse-skills}/controleur-fiscal/";
      agents = [ "opencode" ];
    }
    {
      name = "paperasse-commissaire-aux-comptes";
      source = "${inputs.paperasse-skills}/commissaire-aux-comptes/";
      agents = [ "opencode" ];
    }
    {
      name = "ponytail";
      source = "${inputs.ponytail-skills}/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "cc-golang";
      source = "${inputs.cc-skills-golang}/skills";
      agents = [
        "opencode"
        "vibe"
      ];
      flatten = true;
    }
  ];
}
