{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    services.pipewire.wireplumber.extraConfig."10-ue-boom-fix" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              # Match the physical device address
              "device.address" = "C0:28:8D:45:22:9D";
            }
          ];
          actions = {
            update-props = {
              # This tells WirePlumber to NEVER even try to connect the headset (mic) profiles
              "bluez5.auto-connect" = [ "a2dp_sink" ];

              # Fixes the 'can't update volume' by disabling hardware volume sync
              "bluez5.hw-volume" = false;

              # This forces the device to only show the High Fidelity (A2DP) profile
              "bluez5.roles" = [ "a2dp_sink" ];
            };
          };
        }
      ];
    };
  };
}
