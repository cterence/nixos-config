{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages =
          with pkgs;
          [
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-color-emoji
            liberation_ttf
            fira-code-symbols
            mplus-outline-fonts.githubRelease
            dina-font
            proggyfonts
          ]
          ++ (with pkgs.nerd-fonts; [
            fira-code
            jetbrains-mono
            droid-sans-mono
            meslo-lg
          ]);
        fontconfig.useEmbeddedBitmaps = true; # https://discourse.nixos.org/t/firefox-doesnt-render-noto-color-emojis/51202
      };
    };
}
