{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];
  home.homeDirectory = "/Users/lukasz";
}
