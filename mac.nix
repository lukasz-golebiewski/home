{ config, pkgs, ... }:
let
  mplayer = pkgs.mplayer.override {x264Support = true;};
in {
  imports = [
    ./common.nix
  ];
  home.homeDirectory = "/Users/lukasz";
  home.packages = with pkgs; [
     libiconv
     ntfs3g
     darwin.apple_sdk.frameworks.SystemConfiguration
   ];

  programs.tmux.extraConfig = ''
    set-option -g default-shell /bin/zsh
    set-option -g default-command $SHELL
  '';
}
