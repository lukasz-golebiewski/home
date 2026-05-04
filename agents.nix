{ pkgs, pkgs-unstable, lib, ... }:

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
in

{
  home.packages = with pkgs-unstable; [
    claude-code
    claude-monitor
    gemini-cli
    ollama
  ];

  home.file.".gemini/extensions/caveman" = {
    source = cavemanSrc;
    recursive = true;
  };

  home.file.".claude/plugins/cache/caveman/caveman/${cavemanShort}" = {
    source = cavemanSrc;
    recursive = true;
  };

  home.file.".claude/plugins/marketplaces/caveman" = {
    source = cavemanSrc;
    recursive = true;
  };

  home.file.".claude/plugins/installed_plugins.json".text = builtins.toJSON {
    version = 2;
    plugins = {
      "typescript-lsp@claude-plugins-official" = [{
        scope = "user";
        installPath = "/Users/lukasz/.claude/plugins/cache/claude-plugins-official/typescript-lsp/1.0.0";
        version = "1.0.0";
        installedAt = "2026-03-11T11:26:12.572Z";
        lastUpdated = "2026-03-11T11:26:12.572Z";
        gitCommitSha = "bd041495bd2a1f3e21317f37277b2f5aa152b759";
      }];
      "caveman@caveman" = [{
        scope = "user";
        installPath = "/Users/lukasz/.claude/plugins/cache/caveman/caveman/${cavemanShort}";
        version = cavemanShort;
        installedAt = "2026-04-28T08:09:58.262Z";
        lastUpdated = "2026-04-28T08:09:58.262Z";
        gitCommitSha = cavemanSha;
      }];
    };
  };

  home.file.".claude/plugins/known_marketplaces.json".text = builtins.toJSON {
    "claude-plugins-official" = {
      source = { source = "github"; repo = "anthropics/claude-plugins-official"; };
      installLocation = "/Users/lukasz/.claude/plugins/marketplaces/claude-plugins-official";
      lastUpdated = "2026-05-02T16:16:07.748Z";
    };
    caveman = {
      source = { source = "github"; repo = "JuliusBrussee/caveman"; };
      installLocation = "/Users/lukasz/.claude/plugins/marketplaces/caveman";
      lastUpdated = "2026-04-28T08:09:57.974Z";
    };
  };
}
