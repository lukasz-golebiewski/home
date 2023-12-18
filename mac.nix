{ config, pkgs, ... }:
let
  mplayer = pkgs.mplayer.override {x264Support = true;};
in {
  imports = [
    ./common.nix
  ];
  home.homeDirectory = "/Users/lukasz";
  home.packages = with pkgs; [
     ntfs3g
   ];
}
