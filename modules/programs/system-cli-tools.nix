{
  flake.modules.nixos.cli-tools =
    { pkgs, config, ... }:
    {
      environment.systemPackages = with pkgs; [
        cryptsetup
        curl
        dig
        efibootmgr
        file
        gcc
        git
        gnumake
        gptfdisk
        killall
        libva-utils
        lm_sensors
        lsof
        mlocate
        nano
        net-tools
        openssl
        parted
        pciutils
        tcpdump
        tmux
        tree
        usbutils
        vim
        wget
        whois
      ];

      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 4d --keep 3";
        };
      };
    };
}
