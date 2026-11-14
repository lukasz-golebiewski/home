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

  mcp-server-memory = pkgs.writeShellScriptBin "mcp-server-memory" ''
    # Version pin only; npx still fetches from the registry at runtime.
    exec ${pkgs.nodejs}/bin/npx -y @modelcontextprotocol/server-memory@2026.1.26 "$@"
  '';
in

{
  home.packages = with pkgs-unstable; [
    antigravity-cli
    claude-code
    claude-monitor
    ollama
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

  home.file.".claude/plugins/known_marketplaces.json".force = true;
  home.file.".claude/plugins/known_marketplaces.json".text =
    let home = config.home.homeDirectory; in
    builtins.toJSON {
      "claude-plugins-official" = {
        source = { source = "github"; repo = "anthropics/claude-plugins-official"; };
        installLocation = "${home}/.claude/plugins/marketplaces/claude-plugins-official";
        lastUpdated = "2026-05-02T16:16:07.748Z";
      };
      cellar = {
        source = { source = "github"; repo = "VirtusLab/cellar"; };
        installLocation = "${home}/.claude/plugins/marketplaces/cellar";
        lastUpdated = "2026-05-07T00:00:00.000Z";
      };
    };

}
