{ lib, ... }:
{
  services.hyprpolkitagent.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = lib.mkDefault "ghostty";
      "$fileManager" = lib.mkDefault "nautilus --new-window";
      "$browser" = lib.mkDefault "firefox --new-window --ozone-platform=wayland";
      "$music" = lib.mkDefault "supersonic";
      "$messenger" = lib.mkDefault "signal-desktop";
      "$webapp" = lib.mkDefault "$browser --app";

      input = lib.mkDefault {
        kb_layout = "us";
        kb_variant = "alt-intl";
        kb_options = "compose:caps";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = true;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      # gestures = lib.mkDefault {
      #   workspace_swipe = false;
      # };

      env = [
        "GDK_SCALE,1"

        # Cursor size
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"

        # Cursor theme
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_THEME,Adwaita"

        # Force all apps to use Wayland
        "GDK_BACKEND,wayland"
        "QT_QPA_PLATFORM,wayland"
        "QT_STYLE_OVERRIDE,kvantum"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "OZONE_PLATFORM,wayland"

        # Make Chromium use XCompose and all Wayland
        "CHROMIUM_FLAGS,\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\""

        # Make .desktop files available for wofi
        "XDG_DATA_DIRS,$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share"

        # Use XCompose file
        "XCOMPOSEFILE,~/.XCompose"
        "EDITOR,nvim"

        # GTK theme
        "GTK_THEME,Adwaita:dark"

        # Podman compatibility. Probably need to add cfg.env?
        # "DOCKER_HOST,unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      ];

      exec-once = [
        # "hypridle & mako & waybar & fcitx5"
        # "waybar"
        # "swaybg -i ~/.config/omarchy/current/background -m fill"
        "hyprsunset"
        "systemctl --user start hyprpolkitagent"
        "wl-clip-persist --clipboard regular & clipse -listen"

        # "dropbox-cli start"  # Uncomment to run Dropbox
      ];

      exec = [
        "pkill -SIGUSR2 waybar || waybar"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      # Don't show update on first launch
      ecosystem = {
        no_update_news = true;
      };

      bind = [
        "SUPER, space, exec, wofi --show drun --sort-order=alphabetical"
        "SUPER SHIFT, SPACE, exec, pkill -SIGUSR1 waybar"
        # "SUPER CTRL, SPACE, exec, ~/.local/share/omarchy/bin/swaybg-next"
        # "SUPER SHIFT CTRL, SPACE, exec, ~/.local/share/omarchy/bin/omarchy-theme-next"

        "SUPER, W, killactive,"
        "SUPER, Backspace, killactive,"

        # End active session
        "SUPER, ESCAPE, exec, hyprlock"
        "SUPER SHIFT, ESCAPE, exit,"
        "SUPER CTRL, ESCAPE, exec, reboot"
        "SUPER SHIFT CTRL, ESCAPE, exec, systemctl poweroff"
        "SUPER, K, exec, ~/.local/share/omarchy/bin/omarchy-show-keybindings"

        # Control tiling
        "SUPER, J, togglesplit, # dwindle"
        "SUPER, P, pseudo, # dwindle"
        "SUPER, V, togglefloating,"
        "SUPER SHIFT, Plus, fullscreen,"

        # Move focus with mainMod + arrow keys
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        "SUPER, comma, workspace, -1"
        "SUPER, period, workspace, +1"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Swap active window with the one next to it with mainMod + SHIFT + arrow keys
        "SUPER SHIFT, left, swapwindow, l"
        "SUPER SHIFT, right, swapwindow, r"
        "SUPER SHIFT, up, swapwindow, u"
        "SUPER SHIFT, down, swapwindow, d"

        # Resize active window
        "SUPER, minus, resizeactive, -100 0"
        "SUPER, equal, resizeactive, 100 0"
        "SUPER SHIFT, minus, resizeactive, 0 -100"
        "SUPER SHIFT, equal, resizeactive, 0 100"

        # Scroll through existing workspaces with mainMod + scroll
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"

        # Super workspace floating layer
        "SUPER, S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, movetoworkspace, special:magic"

        # Screenshots
        ", PRINT, exec, hyprshot -m region"
        "SHIFT, PRINT, exec, hyprshot -m window"
        "CTRL, PRINT, exec, hyprshot -m output"

        # Color picker
        "SUPER, PRINT, exec, hyprpicker -a"

        # Clipse
        "CTRL SUPER, V, exec, ghostty --class clipse -e clipse"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        )
      );

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bindel = [
        # Laptop multimedia keys for volume and LCD brightness
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        # Requires playerctl
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        "suppressevent maximize, class:.*"

        # Force chromium into a tile to deal with --app bug
        "tile, class:^(chromium)$"

        # Settings management
        "float, class:^(org.pulseaudio.pavucontrol|blueberry.py)$"

        # Float Steam, fullscreen RetroArch
        "float, class:^(steam)$"
        "fullscreen, class:^(com.libretro.RetroArch)$"

        # Just dash of transparency
        "opacity 0.97 0.9, class:.*"
        # Normal chrome Youtube tabs
        "opacity 1 1, class:^(chromium|google-chrome|google-chrome-unstable)$, title:.*Youtube.*"
        "opacity 1 0.97, class:^(chromium|google-chrome|google-chrome-unstable)$"
        "opacity 0.97 0.9, initialClass:^(chrome-.*-Default)$ # web apps"
        "opacity 1 1, initialClass:^(chrome-youtube.*-Default)$ # Youtube"
        "opacity 1 1, class:^(zoom|vlc|org.kde.kdenlive|com.obsproject.Studio)$"
        "opacity 1 1, class:^(com.libretro.RetroArch|steam)$"

        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

        # Float in the middle for clipse clipboard manager
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
        "stayfocused, class:(clipse)"
      ];

      layerrule = [
        # Proper background blur for wofi
        "blur,wofi"
        "blur,waybar"
      ];
    };
  };
}
