{ pkgs, pkgs-unstable, lib, config, ... }:

let
  cellarVersion = "0.1.0-M7";
  cellarPlatforms = {
    "x86_64-linux" = { archive = "cellar-${cellarVersion}-linux-x86_64.tar.gz"; hash = "sha256-iQaZxMeE7Iu5vhaOFtOOZ5MCRBrE0O/DjtZUT6L6NpQ="; };
    "aarch64-linux" = { archive = "cellar-${cellarVersion}-linux-aarch64.tar.gz"; hash = "sha256-XabTzGAnQOdxIW9GxkCmi/CMT/KQE9ZEV67HAMqGmmc="; };
    "x86_64-darwin" = { archive = "cellar-${cellarVersion}-macos-x86_64.tar.gz"; hash = "sha256-QmJJQHAVP/mlF7Er09lYbrN4YfKwXnznvwnOmIxhVbE="; };
    "aarch64-darwin" = { archive = "cellar-${cellarVersion}-macos-arm64.tar.gz"; hash = "sha256-nsVVyD28xubN5KoGKZgInWdXWaIM3zo7X+nR25t5AUE="; };
  };
  cellarMeta = cellarPlatforms.${pkgs.stdenv.hostPlatform.system};
  cellarBin = pkgs.stdenv.mkDerivation {
    pname = "cellar";
    version = cellarVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/VirtusLab/cellar/releases/download/v${cellarVersion}/${cellarMeta.archive}";
      inherit (cellarMeta) hash;
    };
    sourceRoot = ".";
    nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
      pkgs.glibc
      pkgs.zlib
    ];
    unpackPhase = "tar xzf $src";
    installPhase = ''
      mkdir -p $out/bin
      cp cellar $out/bin/cellar
      chmod +x $out/bin/cellar
    '';
  };

  # Same commit as the v0.1.0-M7 tag, so the skill matches the binary.
  cellarSkill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/VirtusLab/cellar/9eb76cea01896173529a241494c3da3c6479e5a8/skills/cellar/SKILL.md";
    sha256 = "1y7m19rvjs1akabx4qwqfpg3f6x2f5z3d5aaq5qdaf66r937sm49";
  };

  mcpMemoryVersion = "2026.1.26";
  mcpMemoryTarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@modelcontextprotocol/server-memory/-/server-memory-${mcpMemoryVersion}.tgz";
    hash = "sha512-7F0hbaEB4lVqkYhNWmrC5jJjEWPCofgXd7OIk3h97HyvJL6aTAhlUNYaH8lCDxAzlK9sr2pLCkZEYI+m4HSOiA==";
  };
  mcpMemorySrc = pkgs.runCommand "mcp-server-memory-src" { } ''
    mkdir "$out"
    tar -xzf ${mcpMemoryTarball} -C "$out" --strip-components=1
    cp ${./agents/mcp-server-memory/package.json} "$out/package.json"
    cp ${./agents/mcp-server-memory/package-lock.json} "$out/package-lock.json"
  '';
  mcp-server-memory = pkgs.buildNpmPackage {
    pname = "mcp-server-memory";
    version = mcpMemoryVersion;
    src = mcpMemorySrc;
    npmDepsHash = "sha256-oJ+8lDh2hfmhHjAawv2l9pdm/BM60otPpMNjAVNJ52w=";
    dontNpmBuild = true;
    nodejs = pkgs.nodejs_24;
  };
in

{
  home.packages = with pkgs-unstable; [
    antigravity-cli
    claude-code
    claude-monitor
    cellarBin
    mcp-server-memory
  ];

  home.file.".claude/skills/cellar/SKILL.md".source = cellarSkill;

  home.file.".gemini/system-settings.json".text = builtins.toJSON {
    mcpServers = {
      memory = {
        command = "${mcp-server-memory}/bin/mcp-server-memory";
        env = {
          MEMORY_FILE_PATH = "${config.home.homeDirectory}/.gemini/memory.json";
        };
      };
    };
  };

  home.sessionVariables = {
    ANTIGRAVITY_CLI_SYSTEM_SETTINGS_PATH = "${config.home.homeDirectory}/.gemini/system-settings.json";
  };

}
