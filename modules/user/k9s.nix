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
    plugins =
      let
        pluginUrls = [
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/argocd.yaml";
            sha256 = "sha256:0176a2fvz6rck77hbgyii4d8v3sm32kmbp3y829d0grfxri6dq5s";
          }
          {
            url = "https://cloudnative-pg.io/docs/assets/files/plugins-27c6a80c5a835b4a893b11dfba3a87f5.yml";
            sha256 = "sha256:1ry763515dd28wivzxya2a1dcdh9awj020mvszmrzz52zwxjvaf5";
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
            sha256 = "sha256:17g5mdzgf1v7lwy5v2viahcfdcfn8l6i6q20b9r6r5iwls8nmkgx";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/remove-finalizers.yaml";
            sha256 = "sha256:0ppqrsxs65fab7n0nr3jsq3rgnz88ynfw90wyrl2j138hjix0f5f";
          }
          {
            url = "https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins/watch-events.yaml";
            sha256 = "sha256:1sxdykap7kqqjfcrsz9fb6m7573vnglzcah007kn2vcshr3qn26r";
          }
        ];
        fetchAndParsePlugin = urlInfo: readYAML (builtins.fetchurl urlInfo);
      in
      (builtins.foldl' lib.attrsets.recursiveUpdate { } (map fetchAndParsePlugin pluginUrls)).plugins;
  };
}
