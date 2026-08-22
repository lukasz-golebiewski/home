{ pkgs, ... }:
let
  mplayer = pkgs.mplayer.override { x264Support = true; };
in
{
  # services.keybase.enable = true;

  home.homeDirectory = "/home/lukasz";

  home.packages = with pkgs; [
    # kazam
    # keybase-gui
    mplayer
    peek
    # signal-desktop
    vlc
    yt-dlp
  ];

  programs.zsh.shellAliases = {
    # $1 = in, $2 = out - requires mplayer/mencoder from this module
    myencoder = "f(){mencoder $1 -ovc x264 -oac mp3lame -o $2;}; f";
    youtube-dl = "yt-dlp";
  };
}
