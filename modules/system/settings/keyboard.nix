{
  flake.aspects.keyboard.nixos = {
    services.udev.extraRules = ''
      # MonsGeek M1/M-series HID rule
      KERNEL=="hidraw*", ATTRS{idVendor}=="fffe", ATTRS{idProduct}=="0005", MODE="0666", GROUP="users"
    '';
  };
}
