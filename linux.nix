{ config, pkgs, ... }:
let
  mplayer = pkgs.mplayer.override {x264Support = true;};
in {
  imports = [
    ./common.nix
  ];
  # services.keybase.enable = true;

  home.homeDirectory = "/home/lukasz";

  home.packages = with pkgs; [
     # kazam
     # keybase-gui
     mplayer
     peek
     # signal-desktop
     vlc
   ];
}
