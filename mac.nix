{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];
  home.homeDirectory = "/Users/lukasz";
  home.packages = with pkgs; [
     ntfs3g
   ];
}
