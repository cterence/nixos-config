{
  pkgs,
  config,
  ...
}:
let
  tailscale = "${pkgs.tailscale}/bin/tailscale";
in
{
  flake.aspects.ssh.homeManager = {
    programs.ssh = {
      enable = true;
      includes = [ "${config.home.homeDirectory}/.colima/ssh_config" ];
      settings = {
        "*.snow-delta.ts.net" = {
          ProxyCommand = "${tailscale} nc %h %p";
          StrictHostKeyChecking = "accept-new";
        };
        "tailscale-bare" = {
          header = ''Match exec "${tailscale} status 2>/dev/null | grep -qw %h"'';
          ProxyCommand = "${tailscale} nc %h %p";
          StrictHostKeyChecking = "accept-new";
        };
      };
    };
  };
}
