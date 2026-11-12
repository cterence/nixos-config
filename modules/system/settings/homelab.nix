{
  flake.aspects.settings-homelab.nixos =
    { pkgs, config, ... }:
    {
      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 524288;
        "fs.inotify.max_user_instances" = 1024;
      };

      systemd.settings.Manager = {
        DefaultLimitNOFILE = "16384";
      };

      virtualisation.containerd = {
        enable = true;
      };

      # Needed for Longhorn
      environment = {
        systemPackages = with pkgs; [
          mergerfs
          mergerfs-tools
          nfs-utils
          smartmontools
        ];
      };
      services = {
        openssh.enable = true;
        rpcbind.enable = true;
        openiscsi = {
          enable = false;
          name = "iqn.2016-04.com.open-iscsi:" + config.networking.hostName;
        };
      };
      # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1740179416
      systemd = {
        tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];
        services = {
          systemd-timesyncd.serviceConfig.RuntimeMaxSec = "1h";
          tailscaled.serviceConfig.RuntimeMaxSec = "4h";
        };
      };
      networking.firewall = {
        allowedTCPPorts = [
          80
          443
          2049
          6443 # k0s kube-apiserver (worker → controller)
          7946 # k0s etcd member discovery (controller ↔ controller)
          8132 # k0s Konnectivity reverse tunnel (worker → controller)
          9100 # node exporter
          9443 # k0s controller API (controller ↔ controller)
          10250 # kubelet API (controller → worker)
          4244 # cilium hubble flow server (relay → agent)
          4240 # cilium health checks (agent → agent)
          9962 # cilium-agent metrics (prometheus → agent)
          9963 # cilium-operator metrics
          9964 # cilium-envoy metrics
          9965 # hubble flow metrics
          9120 # metallb speaker metrics (prometheus → speaker)
          38081 # catbox health/metrics (prometheus scrapes the hostNetwork port)
        ];
        allowedUDPPorts = [
          8472 # cilium vxlan (pod-to-pod between nodes)
        ];
        extraCommands = ''
          iptables -w -A nixos-fw -s 192.168.1.0/24 -p udp --dport 32768:60999 -j nixos-fw-accept
        '';
      };
    };
}
