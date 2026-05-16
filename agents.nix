{ pkgs, pkgs-unstable, lib, config, ... }:

let
  cavemanSha = "84cc3c14fa1e10182adaced856e003406ccd250d";
  cavemanShort = builtins.substring 0 12 cavemanSha;
  cavemanSrc = pkgs.runCommand "caveman-fixed" { } ''
    cp -r ${pkgs.fetchFromGitHub {
      owner = "JuliusBrussee";
      repo = "caveman";
      rev = "main";
      sha256 = "sha256-LlyBlFsKUHKzsOXEwENoVSsZHtKENVY4vFMRf08vzoU=";
    }} $out
    chmod -R +w $out
    sed -i '/^---$/d' $out/commands/caveman-init.toml
  '';

  cellarVersion = "0.1.0-M7";
  cellarPlatforms = {
    "x86_64-linux"  = { archive = "cellar-${cellarVersion}-linux-x86_64.tar.gz";  hash = "sha256-iQaZxMeE7Iu5vhaOFtOOZ5MCRBrE0O/DjtZUT6L6NpQ="; };
    "aarch64-linux" = { archive = "cellar-${cellarVersion}-linux-aarch64.tar.gz"; hash = "sha256-XabTzGAnQOdxIW9GxkCmi/CMT/KQE9ZEV67HAMqGmmc="; };
    "x86_64-darwin" = { archive = "cellar-${cellarVersion}-macos-x86_64.tar.gz"; hash = "sha256-QmJJQHAVP/mlF7Er09lYbrN4YfKwXnznvwnOmIxhVbE="; };
    "aarch64-darwin" = { archive = "cellar-${cellarVersion}-macos-arm64.tar.gz"; hash = "sha256-nsVVyD28xubN5KoGKZgInWdXWaIM3zo7X+nR25t5AUE="; };
  };
  cellarMeta = cellarPlatforms.${pkgs.system};
  cellarBin = pkgs.stdenv.mkDerivation {
    pname = "cellar";
    version = cellarVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/VirtusLab/cellar/releases/download/v${cellarVersion}/${cellarMeta.archive}";
      hash = cellarMeta.hash;
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
in

{
  home.packages = with pkgs-unstable; [
    claude-code
    claude-monitor
    gemini-cli
    ollama
    cellarBin
  ];

  home.file.".gemini/extensions/caveman" = {
    source = cavemanSrc;
    recursive = true;
  };

  home.file.".gemini/skills/cellar/SKILL.md".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/VirtusLab/cellar/a16116ef0db7e85649a48ca08626e257e3032d2b/skills/cellar/SKILL.md";
    sha256 = "0sgrfl3jl8d8i0x8kw94q5njlzvj663kvz02qslxdbwc188ivsgc";
  };

  home.file.".claude/plugins/known_marketplaces.json".text =
    let home = config.home.homeDirectory; in
    builtins.toJSON {
      "claude-plugins-official" = {
        source = { source = "github"; repo = "anthropics/claude-plugins-official"; };
        installLocation = "${home}/.claude/plugins/marketplaces/claude-plugins-official";
        lastUpdated = "2026-05-02T16:16:07.748Z";
      };
      caveman = {
        source = { source = "github"; repo = "JuliusBrussee/caveman"; };
        installLocation = "${home}/.claude/plugins/marketplaces/caveman";
        lastUpdated = "2026-04-28T08:09:57.974Z";
      };
      cellar = {
        source = { source = "github"; repo = "VirtusLab/cellar"; };
        installLocation = "${home}/.claude/plugins/marketplaces/cellar";
        lastUpdated = "2026-05-07T00:00:00.000Z";
      };
    };

}
