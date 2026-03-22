{
  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        age
        argocd
        bat
        btop
        cmctl
        docker-buildx
        dust
        entr
        eza
        fastfetch
        fd
        ffmpeg
        glab
        htop
        ipcalc
        jq
        jqp
        kind
        kopia
        krew
        kubectl
        kubernetes-helm
        manix
        nil
        nix-init
        nix-inspect
        nix-prefetch
        nix-update
        nixd
        nixfmt
        nmap
        nurl
        nvtopPackages.amd
        p7zip
        postgresql
        pv-migrate
        rclone
        socat
        sops
        tenv
        tfautomv
        tig
        unzip
        velero
        versitygw
        yq-go
        yt-dlp
        zip
      ];

      programs = {
        awscli = {
          enable = true;
          # .aws/config file
          settings = {
            "default" = {
              region = "eu-west-3";
              output = "json";
            };
            "profile default" = {
              sso_start_url = "https://terencech.awsapps.com/start";
              sso_region = "eu-west-3";
              sso_account_name = "terence";
              sso_account_id = "964066691632";
              sso_role_name = "AdministratorAccess";
              region = "eu-west-3";
            };
          };
        };
        k9s = {
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
        };
      };

    };
}
