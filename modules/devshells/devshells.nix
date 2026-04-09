{
  config,
  self,
  inputs,
  ...
}:
let
  forAllSystems = inputs.nixpkgs.lib.genAttrs config.systems;
in
{
  flake.checks = forAllSystems (
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          deadnix.enable = true;
          flake-checker.enable = true;
          gitleaks = {
            name = "gitleaks";
            enable = true;
            entry = "${pkgs.gitleaks}/bin/gitleaks protect -v --staged";
          };
          nil.enable = true;
          nixfmt-rfc-style = {
            package = pkgs.nixfmt;
            enable = true;
          };
          trufflehog = {
            name = "trufflehog";
            enable = true;
            entry = "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --results=verified,unknown --fail";
          };
          statix.enable = true;
        };
      };
    }
  );

  flake.devShells = forAllSystems (
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      # patchedNixosAnywhere = inputs.nixos-anywhere.packages.${system}.default.overrideAttrs (oldAttrs: {
      #   patches = (oldAttrs.patches or [ ]) ++ [
      #     "${inputs.patches}/nixos-anywhere-zram.patch"
      #   ];
      # });
    in
    {
      default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs =
          self.checks.${system}.pre-commit-check.enabledPackages
          ++ (with pkgs; [
            gitleaks
            trufflehog
            nixos-anywhere
          ]);
      };
    }
  );
}
