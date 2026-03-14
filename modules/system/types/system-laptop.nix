{
  flake.modules.nixos.system-laptop = {
    networking.networkmanager.wifi.powersave = true;
  };
}
