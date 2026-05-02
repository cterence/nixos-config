let
  StateDirectory = "dnscrypt-proxy";
in
{
  flake.aspects.networking.nixos = {
    networking = {
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

    services.dnsmasq = {
      enable = true;
      settings = {
        server = [
          "1.1.1.1"
          "9.9.9.9"
          "/snow-delta.ts.net/100.100.100.100"
          "/ts.net/100.100.100.100"
          "/100.in-addr.arpa/100.100.100.100"
        ];
        listen-address = [
          "127.0.0.1"
          "::1"
        ];
        domain-needed = true;
        bind-interfaces = true;
      };
    };

    services.dnscrypt-proxy = {
      enable = false;
      settings = {
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3"; # See https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md gitleaks:allow
          cache_file = "/var/lib/${StateDirectory}/public-resolvers.md";
        };

        ipv6_servers = true;
        block_ipv6 = false;
        require_dnssec = true;
        require_nolog = true;
        require_nofilter = true;

        forwarding_rules = "/etc/dnscrypt-proxy/forwarding-rules.txt";
      };
    };

    environment.etc."dnscrypt-proxy/forwarding-rules.txt".text = ''
      # Forward Tailscale MagicDNS queries to the Tailscale internal IP
      ts.net 100.100.100.100
      tailscale.net 100.100.100.100
      100.in-addr.arpa 100.100.100.100
    '';

    systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = StateDirectory;
  };
}
