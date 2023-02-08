{ config, pkgs, ... }:

let
  emacs-overlay = import (builtins.fetchTarball {
    url =
      "https://github.com/nix-community/emacs-overlay/archive/c1eb5198d74d4f3d3ca2522bf8e2a4d04f5688a9.tar.gz";
  });
in {
  nixpkgs.overlays = [ emacs-overlay ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lukasz";
  home.homeDirectory = "/home/lukasz";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    dotfiles
    fortune
    htop
    plantuml
    silver-searcher #ag
  ];

  services.emacs.enable = true;
  programs.emacs.enable = true;
  programs.emacs.extraPackages = epkgs: [
    epkgs.ace-window
    epkgs.ag
    epkgs.avy
    epkgs.bind-key
    epkgs.company
    epkgs.csv-mode
    epkgs.direnv
    epkgs.dockerfile-mode
    epkgs.dumb-jump
    epkgs.elmacro
    epkgs.eno
    epkgs.evil
    epkgs.evil-collection
    epkgs.evil-iedit-state
    epkgs.evil-leader
    epkgs.evil-mc
    epkgs.evil-surround
    epkgs.fireplace
    epkgs.flycheck
    # epkgs.git-gutter-fringe
    # epkgs.git-timemachine
    epkgs.graphviz-dot-mode
    epkgs.helm
    epkgs.helm-ag
    epkgs.helm-projectile
    epkgs.helm-swoop
    epkgs.hydra
    epkgs.idris-mode
    epkgs.key-chord
    epkgs.nyan-mode
    epkgs.magit
    epkgs.markdown-mode
    epkgs.monokai-theme
    epkgs.nix-mode
    epkgs.plantuml-mode
    epkgs.projectile
    epkgs.smex
    epkgs.smartparens
    epkgs.suggest
    epkgs.undo-tree
    epkgs.use-package
    epkgs.vimish-fold
    epkgs.vlf
    epkgs.which-key
    epkgs.yaml-mode
    epkgs.yasnippet
    epkgs.zoom-window
  ];
  home.file = {
    ".emacs.d" = {
      source = ./emacs.d;
      recursive = true;
    };
  };

  programs.tmux.enable = true;
  programs.tmux.plugins = with pkgs; [
    tmuxPlugins.sensible
    tmuxPlugins.resurrect
    tmuxPlugins.yank
    tmuxPlugins.copycat
    {
      plugin = tmuxPlugins.continuum;
      extraConfig = "set -g @continuum-restore 'off'";
    }
  ];
  programs.tmux.extraConfig = ''
    set -g prefix ^a
    set -g terminal-overrides 'xterm*:smcup@:rmcup@'
    unbind %
    #bind | split-window -h
    #bind - split-window -v
    bind N break-pane
    # Set status bar
    set -g status-bg black
    set -g status-fg white
    # Highlight active window
    set-window-option -g window-status-current-style bg=blue

    # Set window notifications
    setw -g monitor-activity on
    set -g visual-activity on

    # Automatically set window title
    setw -g automatic-rename

    bind | split-window -h -c '#{pane_current_path}'  # Split panes horizontal
    bind - split-window -v -c '#{pane_current_path}'  # Split panes vertically

    # pane movement
    bind-key j command-prompt -p "join pane from:"  "join-pane -s '%%'"
    bind-key s command-prompt -p "send pane to:"  "join-pane -t '%%'"

    set-window-option -g mode-keys vi
  '';

  # programs.emacs.extraConfig = ''
          # (setq standard-indent 2)
        # '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
