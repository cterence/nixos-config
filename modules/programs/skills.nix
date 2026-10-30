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
    mattpocock-skills = {
      flake = false;
      url = "github:mattpocock/skills";
    };
    paperasse-skills = {
      flake = false;
      url = "github:romainsimon/paperasse";
    };
    ponytail-skills = {
      flake = false;
      url = "github:DietrichGebert/ponytail";
    };
    spf13-go-skills = {
      flake = false;
      url = "github:spf13/go-skills";
    };
    spf13-cli-style-skills = {
      flake = false;
      url = "github:spf13/cli-style";
    };
    wshobson-skills = {
      flake = false;
      url = "github:wshobson/agents";
    };
    rea-skills = {
      flake = false;
      url = "github:morluto/rea/rea-agents-6.5.0";
    };
    taste-skill = {
      flake = false;
      url = "github:Leonxlnx/taste-skill";
    };
    cursor-plugins = {
      flake = false;
      url = "github:cursor/plugins";
    };
    trailofbits-skills = {
      flake = false;
      url = "github:trailofbits/skills";
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
      name = "go";
      dir = "go-skills";
      source = "${inputs.spf13-go-skills}/go";
      agents = [
        "opencode"
        "vibe"
      ];
    }
    {
      name = "cli-style";
      source = "${inputs.spf13-cli-style-skills}/cli-style";
      agents = [ "vibe" ];
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
      name = "mobile-android-design";
      source = "${inputs.wshobson-skills}/plugins/ui-design/skills/mobile-android-design";
      agents = [ "vibe" ];
    }
    {
      name = "grill-me";
      source = "${inputs.mattpocock-skills}/skills/productivity/grill-me";
      agents = [ "vibe" ];
    }
    {
      name = "grilling";
      source = "${inputs.mattpocock-skills}/skills/productivity/grilling";
      agents = [ "vibe" ];
    }
    {
      name = "rea";
      source = "${inputs.rea-skills}/.agents/skills";
      agents = [ "vibe" ];
      flatten = true;
      exclude = [
        "rea-changelog-update"
        "rea-ci-tests-audit"
        "rea-tool-design"
      ];
    }
    {
      name = "taste-skill";
      source = "${inputs.taste-skill}/skills/taste-skill";
      agents = [ "vibe" ];
    }
    {
      name = "thermo-nuclear-code-quality-review";
      source = "${inputs.cursor-plugins}/cursor-team-kit/skills/thermo-nuclear-code-quality-review";
      agents = [ "vibe" ];
    }
    {
      name = "code-improver";
      source = "${inputs.trailofbits-skills}/plugins/code-improver/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "patching-bugs";
      source = "${inputs.trailofbits-skills}/plugins/patching-bugs/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "regression-hunt";
      source = "${inputs.trailofbits-skills}/plugins/regression-hunt/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "static-analysis";
      source = "${inputs.trailofbits-skills}/plugins/static-analysis/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "mutation-testing";
      source = "${inputs.trailofbits-skills}/plugins/mutation-testing/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "property-based-testing";
      source = "${inputs.trailofbits-skills}/plugins/property-based-testing/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "differential-review";
      source = "${inputs.trailofbits-skills}/plugins/differential-review/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "second-opinion";
      source = "${inputs.trailofbits-skills}/plugins/second-opinion/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "sharp-edges";
      source = "${inputs.trailofbits-skills}/plugins/sharp-edges/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "goal-prompt";
      source = "${inputs.trailofbits-skills}/plugins/goal-prompt/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "gh-cli";
      source = "${inputs.trailofbits-skills}/plugins/gh-cli/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
    {
      name = "github-triage";
      source = "${inputs.trailofbits-skills}/plugins/github-triage/skills";
      agents = [ "vibe" ];
      flatten = true;
    }
  ];
}
