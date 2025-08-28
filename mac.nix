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
     watch
   ];

  programs.tmux.extraConfig = ''
    set-option -g default-shell /bin/zsh
    set-option -g default-command $SHELL
  '';

  programs.zsh = {
    initContent = ''
      # Source the Nix profile for proper environment
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
  };
}
