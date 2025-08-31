{ pkgs, ... }:

let
  emacs-overlay = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/emacs-overlay/archive/10f086f.tar.gz";
  });
in {
  nixpkgs.overlays = [ emacs-overlay ];

  # services.emacs.enable = true;
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
    extraPackages = epkgs: [
      epkgs.ace-window
      epkgs.ag
      epkgs.avy
      epkgs.bind-key
      epkgs.company
      epkgs.csv-mode
      epkgs.dap-mode
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
      epkgs.git-gutter-fringe
      epkgs.git-timemachine
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
      epkgs.kotlin-mode
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
      epkgs.rjsx-mode
      epkgs.rust-mode
      epkgs.sbt-mode
      epkgs.scala-mode
      epkgs.smex
      epkgs.smartparens
      epkgs.suggest
      epkgs.terraform-mode
      epkgs.typescript-mode
      epkgs.undo-tree
      epkgs.use-package
      epkgs.vimish-fold
      epkgs.vlf
      epkgs.web-mode
      epkgs.which-key
      epkgs.yaml-mode
      epkgs.yasnippet
      epkgs.zoom-window
    ];
  };
  home.file = {
    ".emacs.d" = {
      source = ./emacs.d;
      recursive = true;
    };
  };
}
