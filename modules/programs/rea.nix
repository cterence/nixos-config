{
  flake.aspects.rea.homeManager =
    { pkgs, ... }:
    {
      # MCP server launcher for the rea reverse-engineering tools (vibe
      # [[mcp_servers]] entry "rea"). Pinned to the rea-agents release.
      home.file.".local/bin/rea-mcp".source = "${pkgs.writeShellScriptBin "rea-mcp" ''
        export GHIDRA_INSTALL_DIR="${pkgs.ghidra}/lib/ghidra"
        export JAVA_HOME="${pkgs.jdk21}/lib/openjdk"
        export REA_ANALYSIS_PROVIDER=ghidra
        export PATH="${pkgs.nodejs}/bin:$PATH"
        exec npx -y rea-agents@6.5.0 mcp
      ''}/bin/rea-mcp";
    };
}
