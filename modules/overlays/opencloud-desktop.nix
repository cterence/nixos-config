{
  # Finder sync ext needs a full Xcode, absent on Hydra (nixpkgs#563742).
  flake.overlays.opencloud-desktop = _final: prev: {
    opencloud-desktop = prev.opencloud-desktop.overrideAttrs (
      _:
      {
        cmakeFlags = [ "-DBUILD_SHELL_INTEGRATION=OFF" ];
      }
      // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
        versionCheckProgram = "${placeholder "out"}/Applications/KDE/OpenCloud.app/Contents/MacOS/opencloudcmd";
        # wrapQtAppsHook replaces the vfs plugin with a Mach-O executable
        # QPluginLoader can't load; restore the bundle or sync setup fails.
        postFixup = ''
          mv "$out/Applications/KDE/OpenCloud.app/Contents/PlugIns/.OpenCloud_vfs_off.so-wrapped" \
            "$out/Applications/KDE/OpenCloud.app/Contents/PlugIns/OpenCloud_vfs_off.so"
        '';
      }
    );
  };
}
