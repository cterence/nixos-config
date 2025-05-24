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
      let
        pluginUrls = [
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/argocd.yaml";
            sha256 = "sha256:0176a2fvz6rck77hbgyii4d8v3sm32kmbp3y829d0grfxri6dq5s";
          }
          {
            url = "https://cloudnative-pg.io/documentation/current/samples/k9s/plugins.yml";
            sha256 = "sha256:1jj75adq5szp0rap5gpsfmqv12wb6xm7z40x1saiikmcwyajxxqw";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/blame.yaml";
            sha256 = "sha256:0rzxzxvp8brgh1xjainpk2dq269ak6xpmb5h7ibzx4wahcnrkgc3";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/cert-manager.yaml";
            sha256 = "sha256:1ak5cks7r6s21y55ljy7c7v0y8nyid4kxrxiiqd6vq1p774izj6g";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/external-secrets.yaml";
            sha256 = "sha256:1mmpdinkjav323igfms1hy1aprlzngf6vls95ml4p7z72nlhkksx";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/remove-finalizers.yaml";
            sha256 = "sha256:0ppqrsxs65fab7n0nr3jsq3rgnz88ynfw90wyrl2j138hjix0f5f";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/watch-events.yaml";
            sha256 = "sha256:145disab0290vy59a0h6lmh0qa1kv10swdn5hxcqczgcrbxplbqx";
          }
        ];
        fetchAndParsePlugin = urlInfo: readYAML (builtins.fetchurl urlInfo);
      in
      builtins.foldl' lib.attrsets.recursiveUpdate { } (map fetchAndParsePlugin pluginUrls);
  };
}
