{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.enableSshAddKeys = lib.mkEnableOption "Automatically add all SSH keys to the SSH agent on boot";

  config.systemd.user = {
    services.add-ssh-keys = lib.mkIf config.enableSshAddKeys {
      Unit = {
        Description = "Add all SSH keys to the SSH agent";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "add-ssh-keys" ''
          #!/run/current-system/sw/bin/bash

          set -euo pipefail

          # Start the ssh-agent if not already running
          if ! ${pkgs.procps}/bin/pgrep -u "$USER" ssh-agent > /dev/null; then
              eval "$(${pkgs.openssh}/bin/ssh-agent -s)"
              echo "Started agent because it was not running"
          fi

          # Add all valid private keys to the agent
          for key in ~/.ssh/*; do
              if [[ -f "$key" && "$key" != *.pub && "$(${pkgs.coreutils}/bin/head -c 5 "$key")" == "-----" ]]; then
                  ${pkgs.openssh}/bin/ssh-add "$key" 2>/dev/null
                  echo "Added $key to SSH agent"
              fi
          done
        ''}";
      };
    };

    timers.add-ssh-keys = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Timer = {
        OnBootSec = "1m";
        Unit = "add-ssh-keys.service";
      };
    };
  };
}
