{ pkgs, ... }:
{
  systemd.user = {
    services.add-ssh-keys = {
      Unit = {
        Description = "Add all SSH keys to the SSH agent";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "add-ssh-keys" ''
          #!/run/current-system/sw/bin/bash

          # Start the ssh-agent if not already running
          if ! pgrep -u "$USER" ssh-agent > /dev/null; then
              eval "$(ssh-agent -s)"
              echo "Started agent because it was not running"
          fi

          # Add all valid private keys to the agent
          for key in ~/.ssh/*; do
              if [[ -f "$key" && "$key" != *.pub && "$(head -c 5 "$key")" == "-----" ]]; then
                  ssh-add "$key" 2>/dev/null
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
