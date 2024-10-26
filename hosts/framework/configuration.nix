# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  plasma-manager,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/desktop.nix
    ../../modules/system/kde-plasma.nix
    inputs.home-manager.nixosModules.default
  ];

  # https://wiki.archlinux.org/title/Framework_Laptop_13#Headset_jack
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  boot.kernelParams = [
    # https://gitlab.freedesktop.org/drm/amd/-/issues/3187
    "amdgpu.sg_display=0"
  ];

  nixpkgs.overlays = [
    outputs.overlays.additions
  ];

  # Workaround for gdm
  # See: https://github.com/NixOS/nixpkgs/issues/171136
  # See: https://github.com/NixOS/nixpkgs/pull/171140
  security.pam.services.login.fprintAuth = false;
  security.pam.services.gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
    text = ''
      auth       required                    pam_shells.so
      auth       requisite                   pam_nologin.so
      auth       requisite                   pam_faillock.so      preauth
      auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
      auth       optional                    pam_permit.so
      auth       required                    pam_env.so
      auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
      auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
      account    include                     login
      password   required                    pam_deny.so
      session    include                     login
      session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    '';
  };

  services = {
    fprintd.enable = true;
    kolide-launcher.enable = true;
    printing.enable = true;
  };
  sops = {
    secrets = {
      "kolide-k2-secret" = {
        path = "/etc/kolide-k2/secret";
        mode = "0440";
        group = config.users.groups.keys.name;
        sopsFile = ./secrets.yaml;
      };
    };
  };

  environment = {
    systemPackages =
      with pkgs;
      [
        aws-vault
        azure-cli
        bruno
        # checkov
        copilot-cli
        filezilla
        git-crypt
        glab
        google-chrome
        k6
        kubent
        kubeshark
        netcat-gnu
        networkmanager-openvpn
        networkmanager-vpnc
        openfortivpn
        pre-commit
        python311Packages.boto3
        python311Packages.numpy
        redis
        slack
        sshuttle
        ssm-session-manager-plugin
        sq
        teams-for-linux
        tflint
        tflint-plugins.tflint-ruleset-aws
        tflint-plugins.tflint-ruleset-google
        typora
        vault
        yatas
      ]
      ++ [
        aws-sso-util
        inputs.baywatch.packages.x86_64-linux.default
        google-chat-linux
        guacamole
        openfortivpn-webview
        playground
      ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
    users = {
      "terence" = import ./home.nix;
    };
  };

  networking = {
    hostName = "framework"; # Define your hostname.
  };

  system = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = "24.05"; # Did you read the comment?
  };
}
