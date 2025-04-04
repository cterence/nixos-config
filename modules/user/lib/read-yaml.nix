{
  lib,
  remarshal,
  runCommand,
}:

# Read a YAML file into a Nix datatype using IFD.
#
# Similar to:
#
# > builtins.fromJSON (builtins.readFile ./somefile)
#
# but takes an input file in YAML instead of JSON.
#
# readYAML :: Path -> a
#
# where `a` is the Nixified version of the input file.
path:

let
  # Starting in remarshal-0.17.0, it added a new `--stringify` CLI flag:
  # https://github.com/remarshal-project/remarshal/releases/tag/v0.17.0
  # If you DO NOT pass this flag, then remarshal throws an error when
  # converting from YAML to JSON if your input YAML file contains a datetime
  # node.  See https://github.com/cdepillabout/stacklock2nix/pull/55
  # for more information.
  remarshal-stringify-arg =
    if lib.versionAtLeast remarshal.version "0.17.0" then "--stringify" else "";

  jsonOutputDrv = runCommand "from-yaml" {
    nativeBuildInputs = [ remarshal ];
  } "remarshal ${remarshal-stringify-arg} -if yaml -i \"${path}\" -of json -o \"$out\"";
in
builtins.fromJSON (builtins.readFile jsonOutputDrv)
