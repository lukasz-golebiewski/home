{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];
  services.keybase.enable = true;

  home.homeDirectory = "/home/lukasz";

  home.packages = with pkgs; [
     # kazam
     keybase-gui
     peek
   ];
}
