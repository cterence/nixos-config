{
  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        age
        appimage-run
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
        yq
        yt-dlp
        zip
      ];

      programs.awscli = {
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
    };
}
