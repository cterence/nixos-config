let
  StateDirectory = "dnscrypt-proxy";
in
{
  flake.aspects.networking.nixos = {
    networking = {
      nameservers = [
        "127.0.0.1"
      ];
      # Trying search domain only on domain with < 1 dot
      resolvconf.extraOptions = [
        "ndots:1"
      ];
      search = [ "snow-delta.ts.net" ];
      networkmanager = {
        enable = true;
        dns = "none";
      };
    };

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3"; # See https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md gitleaks:allow
          cache_file = "/var/lib/${StateDirectory}/public-resolvers.md";
        };

        ipv6_servers = false;
        block_ipv6 = true;
        require_dnssec = true;
        require_nolog = false;
        require_nofilter = true;

        forwarding_rules = "/etc/dnscrypt-proxy/forwarding-rules.txt";
      };
    };

    environment.etc."dnscrypt-proxy/forwarding-rules.txt".text = ''
      # Forward Tailscale MagicDNS queries to the Tailscale internal IP
      ts.net 100.100.100.100
      tailscale.net 100.100.100.100
    '';

    systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = StateDirectory;
  };
}
