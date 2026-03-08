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
  flake.checks = forAllSystems (system: {

    pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        gitleaks = {
          name = "gitleaks";
          enable = true;
          entry = "${inputs.nixpkgs.legacyPackages.${system}.gitleaks}/bin/gitleaks protect -v --staged";
        };
        nil.enable = true;
        nixfmt-rfc-style = {
          package = inputs.nixpkgs.legacyPackages.${system}.nixfmt;
          enable = true;
        };
        trufflehog = {
          name = "trufflehog";
          enable = true;
          entry = "${
            inputs.nixpkgs.legacyPackages.${system}.trufflehog
          }/bin/trufflehog git file://. --since-commit HEAD --results=verified,unknown --fail";
        };
        statix.enable = true;
      };
    };
  });

  flake.devShells = forAllSystems (system: {
    default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
      inherit (self.checks.${system}.pre-commit-check) shellHook;
      buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
    };
  });
}
