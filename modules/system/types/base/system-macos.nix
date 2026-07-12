{
  flake.aspects.system-macos.darwin =
    let
      username = "terence";
    in
    {
      security.pam.services.sudo_local.touchIdAuth = true;
      system = {
        primaryUser = username;
        defaults = {
          dock = {
            autohide = true;
            autohide-time-modifier = 0.50;
            autohide-delay = 0.0;
            minimize-to-application = true;
            show-recents = false;
            orientation = "right";
            static-only = false;
            tilesize = 40;
          };
          finder = {
            AppleShowAllFiles = true;
            AppleShowAllExtensions = true;
            ShowPathbar = true;
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "clmv";
            ShowStatusBar = true;
          };
          trackpad = {
            Clicking = true;
          };
          NSGlobalDomain = {
            ApplePressAndHoldEnabled = false;
            KeyRepeat = 2;
            InitialKeyRepeat = 15;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticInlinePredictionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            AppleInterfaceStyle = "Dark";
          };
          CustomUserPreferences = {
            ".GlobalPreferences" = {
              NSUserQuotesArray = [
                "\""
                "\""
                "'"
                "'"
              ];
              NSQuitAlwaysKeepsWindows = false;
            };
            "com.apple.WindowManager" = {
              RestorePersistentStateOnLaunch = false;
            };
            # Settings of plist in /Users/${username}/Library/Preferences/
            "com.apple.finder" = {
              # Set home directory as startup window
              NewWindowTargetPath = "file:///Users/${username}/";
              NewWindowTarget = "PfHm";
              # Set search scope to directory
              FXDefaultSearchScope = "SCcf";
              # Multi-file tab view
              FinderSpawnTab = true;
            };
            "com.apple.desktopservices" = {
              # Disable creating .DS_Store files in network an USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
            # Show battery percentage
            "/Users/${username}/Library/Preferences/ByHost/com.apple.controlcenter".BatteryShowPercentage =
              true;
            # Privacy
            "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
          };
        };
      };
    };
}
