{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      programs = {
        go.enable = true;
        vscode = {
          enable = true;
          package = pkgs.vscode.overrideAttrs (previousAttrs: {
            postFixup = previousAttrs.postFixup + ''
              sed -i -e "s|StartupWMClass=.*|StartupWMClass=code-url-handler|" $out/share/applications/code-url-handler.desktop
            '';
          });
        };
      };
    };
}
