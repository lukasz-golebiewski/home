{ pkgs, pkgs-unstable, lib, config, ... }:

let
  cellarVersion = "0.1.0-M14";
  cellarPlatforms = {
    "x86_64-linux" = { archive = "cellar-${cellarVersion}-linux-x86_64.tar.gz"; hash = "sha256-8w2ngwKo7h+TVwuynx6TVAmXJlcjJ/x97e4dxDr8sSw="; };
    "aarch64-linux" = { archive = "cellar-${cellarVersion}-linux-aarch64.tar.gz"; hash = "sha256-UPO/4D+ojEwOL5swSdUEdPgxu/hEIIxfcVCHTKQT9+8="; };
    "x86_64-darwin" = { archive = "cellar-${cellarVersion}-macos-x86_64.tar.gz"; hash = "sha256-WJ3F9nhHwza4bEaCjxlpwXdN9fAwcVeNXNltWaM6TUY="; };
    "aarch64-darwin" = { archive = "cellar-${cellarVersion}-macos-arm64.tar.gz"; hash = "sha256-eHYaLzqRflStzL/03BgZZ9KbCz25LHBkmezSDaadTnM="; };
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

  # Same commit as the v0.1.0-M14 tag, so the skill matches the binary.
  cellarSkill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/VirtusLab/cellar/69540b26e0b06388573a9f36feb408126657dfe2/skills/cellar/SKILL.md";
    sha256 = "sha256-TmyRtJ3JNA0fAzryzz+/AdGYdE0wXBRONjNZvntRr0c=";
  };

  mcpMemoryVersion = "2.1.1";
  mcpMemoryTarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@modelcontextprotocol/server-memory/-/server-memory-${mcpMemoryVersion}.tgz";
    hash = "sha512-MbjK6Pi+uGU3EwGk9HyCp/1zKwnuB/QMQ/wQOlswaLgHzIeeCuyVdWUTWg0hTGBk+n+3l5la5a4egbt8YuoVAg==";
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
    npmDepsHash = "sha256-xA3NIaUhxMNmGXo7iCVSJui79483Pkpj498+AEpnHuQ=";
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
