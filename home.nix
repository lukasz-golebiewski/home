{ config, pkgs, ... }:

let
  emacs-overlay = import (builtins.fetchTarball {
    url =
      "https://github.com/nix-community/emacs-overlay/archive/3fc7717.tar.gz";
  });
  linux-packages =
   if pkgs.system == "x86_64-linux" then with pkgs; [
     kazam
     peek
   ] else [];
in {
  nixpkgs.overlays = [ emacs-overlay ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lukasz";
  home.homeDirectory = if pkgs.system == "x86_64-linux" then "/home/lukasz" else "/Users/lukasz";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    cachix
    direnv
    dotfiles
    fortune
    gnugrep
    htop
    nix-direnv
    openvpn
    plantuml
    silver-searcher #ag
  ] ++ linux-packages;

  # services.emacs.enable = true;
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
    epkgs.elm-mode
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
    epkgs.haskell-mode
    epkgs.helm
    epkgs.helm-ag
    epkgs.helm-lsp
    epkgs.helm-projectile
    epkgs.helm-swoop
    epkgs.hydra
    epkgs.idris-mode
    epkgs.key-chord
    epkgs.lsp-metals
    epkgs.lsp-mode
    epkgs.lsp-haskell
    epkgs.lsp-ui
    epkgs.nyan-mode
    epkgs.magit
    epkgs.markdown-mode
    epkgs.monokai-theme
    epkgs.multiple-cursors
    epkgs.nix-mode
    epkgs.plantuml-mode
    epkgs.projectile
    epkgs.rust-mode
    epkgs.sbt-mode
    epkgs.scala-mode
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

  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
    shellAliases = {
      "du." = "du -d 1 -h";
    };
    localVariables = {
      EDITOR = "emacsclient";
    };
    plugins = with pkgs; [
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
      {
        name = "history-search-multi-word";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "history-search-multi-word";
          rev = "458e75c";
          sha256 = "6B8uoKJm3gWmufsnLJzLEdSm1tQasrs2fUmS0pDsdMw=";
        };
      }
      {
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "da8dee3";
          sha256 = "MHb9Q7mwgWAs99vom6a2aODB40I9JTBaJnbvTYbMwiA=";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "z"
      ];
      theme = "ys";
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

  programs.git = {
    enable = true;
    userEmail = "lukasz.golebiewski@gmail.com";
    userName = "Łukasz Gołębiewski";
    signing.key = "3A04B66138A452AD9190A989C4F0E4E500C5DA8B";
    signing.signByDefault = true;
    extraConfig = {
      github = { user = "lukasz.golebiewski"; };
      merge = { conflictstyle = "diff3"; };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
