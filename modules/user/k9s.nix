{ pkgs, lib, ... }:
let
  readYAML = pkgs.callPackage ./lib/read-yaml.nix { };
in
{
  programs.k9s = {
    enable = true;
    aliases = {
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
    };
    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        refreshRate = 2;
        maxConnRetry = 5;
        readOnly = false;
        noExitOnCtrlC = false;
        ui = {
          enableMouse = false;
          headless = true;
          logoless = true;
          crumbsless = false;
          reactive = false;
          noIcons = false;
        };
        skipLatestRevCheck = true;
        disablePodCounting = false;
        shellPod = {
          image = "busybox";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
          tty = true;
        };
        imageScans = {
          enable = false;
          exclusions = {
            namespaces = [ ];
            labels = { };
          };
        };
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = 300;
          fullScreen = false;
          textWrap = true;
          showTime = false;
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
      };
    };
    plugin =
      lib.attrsets.recursiveUpdate
        (readYAML (
          builtins.fetchurl {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/argocd.yaml";
            sha256 = "sha256:0176a2fvz6rck77hbgyii4d8v3sm32kmbp3y829d0grfxri6dq5s";
          }
        ))
        (
          lib.attrsets.recursiveUpdate
            (readYAML (
              builtins.fetchurl {
                url = "https://cloudnative-pg.io/documentation/current/samples/k9s/plugins.yml";
                sha256 = "sha256:048r0nip3xggrgikplk117r0ffmz57mh211mcnj1grw6vjp93c5g";
              }
            ))
            (
              readYAML (
                builtins.fetchurl {
                  url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/blame.yaml";
                  sha256 = "sha256:0rzxzxvp8brgh1xjainpk2dq269ak6xpmb5h7ibzx4wahcnrkgc3";
                }
              )
            )
        );
  };
}
