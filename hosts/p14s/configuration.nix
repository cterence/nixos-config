# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  outputs,
  pkgs,
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

  nixpkgs.overlays = [
    inputs.nix-alien.overlays.default
    outputs.overlays.additions
    outputs.overlays.pkgs-vlc3-0-20
  ];

  # Workaround for gdm
  # See: https://github.com/NixOS/nixpkgs/issues/171136
  # See: https://github.com/NixOS/nixpkgs/pull/171140
  security.pam.services.login.fprintAuth = false;
  # security.pam.services.gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
  #   text = ''
  #     auth       required                    pam_shells.so
  #     auth       requisite                   pam_nologin.so
  #     auth       requisite                   pam_faillock.so      preauth
  #     auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
  #     auth       optional                    pam_permit.so
  #     auth       required                    pam_env.so
  #     auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
  #     auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
  #     account    include                     login
  #     password   required                    pam_deny.so
  #     session    include                     login
  #     session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
  #   '';
  # };

  services = {
    fprintd.enable = true;
    printing = {
      enable = true;
    };
    # Printer autodiscovery
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  sops = {
    secrets = {
    };
  };

  environment = {
    systemPackages = with pkgs; [
      aws-sso-util
      aws-vault
      bruno
      copilot-cli
      filezilla
      git-crypt
      git-filter-repo
      glab
      google-chat-linux
      google-chrome
      greenmask
      har-to-k6
      k6
      kubent
      kubeshark
      mysql-shell
      netcat-gnu
      networkmanager-openvpn
      networkmanager-vpnc
      obs-studio
      openfortivpn
      openfortivpn-webview
      pipenv
      pre-commit
      python313Packages.boto3
      python313Packages.numpy
      redis
      slack
      sq
      sshuttle
      ssm-session-manager-plugin
      tflint
      tflint-plugins.tflint-ruleset-aws
      tflint-plugins.tflint-ruleset-google
      typora
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
    hostName = "p14s"; # Define your hostname.
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
    stateVersion = "25.05"; # Did you read the comment?
  };
}
