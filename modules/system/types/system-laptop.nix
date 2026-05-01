{
  flake.aspects.system-laptop.nixos = {
    networking.networkmanager.wifi.powersave = true;
  };
}
