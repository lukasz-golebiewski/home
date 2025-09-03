{ config, pkgs, ... }:

let
in {
  imports = [
    ./emacs.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lukasz";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    awscli2
    buf
    cachix
    direnv
    dotfiles
    eksctl
    ffmpeg
    fluxcd
    fortune
    google-cloud-sdk
    gnugrep
    htop
    jq
    k9s
    kubectl
    kubernetes-helm
    metals
    nil
    nix-direnv
    nixpkgs-fmt
    nodePackages.typescript-language-server
    openvpn
    pass
    plantuml
    sbt-extras
    signal-export
    silver-searcher #ag
    tmate
    typescript
    vim
    x264
  ];

  nix = {
    package = pkgs.nix;
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cache.iog.io"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          dracula-theme.theme-dracula
          vscodevim.vim
          yzhang.markdown-all-in-one
          kahole.magit
          rust-lang.rust-analyzer
          jnoortheen.nix-ide
          scala-lang.scala
          scalameta.metals
          github.copilot
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools
        ];
        keybindings = [
        {
          key = "k";
          command = "cursorUp";
          when = "resourceScheme == magit && vim.active && vim.mode == 'Normal'";
        }
        ];
        userSettings = {
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = ["nixpkgs-fmt"];
              };
            };
          };
          "vim.leader" = "<space>";
          "vim.normalModeKeyBindingsNonRecursive" = [
            {
              before = ["<leader>" "l" "f" "d"];
              commands = ["editor.action.revealDefinition"];
            }
            {
              before = ["<leader>" "x" "c"];
              commands = ["workbench.action.showCommands"];
            }
            {
              before = ["<leader>" "x" "o"];
              commands = ["workbench.action.nextEditor"];
            }
            {
              before = ["<leader>" "x" "p"];
              commands = ["workbench.action.previousEditor"];
            }
            {
              before = ["<leader>" "x" "q"];
              commands = ["workbench.action.quit"];
            }
            {
              before = ["<leader>" "s"];
              commands = ["workbench.action.files.save"];
            }
            {
              before = ["<leader>" "g" "s"];
              commands = ["magit.status"];
            }
          ];
          "files.watcherExclude" = {
            "**/.bloop" = true;
            "**/.metals" = true;
          };
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
      eval "$(direnv hook zsh)"
      prompt_nix_shell_setup
    '';
    shellAliases = {
      "du." = "du -d 1 -h";
      # $1 = in, $2 = out - requires mplayer
      "myencoder" = "f(){mencoder $1 -ovc x264 -oac mp3lame -o $2;}; f";
      "myffmpeg-old" = "f(){ffmpeg -i $1 -c:v libx264 -crf 23 $2;}; f";
      "myffmpeg" = "f(){ffmpeg -i $1 -c:v vp9 -crf 23 $2;}; f";
      "k" = "kubectl";
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
      {
        name = "nix-zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "nix-community";
          repo = "nix-zsh-completions";
          rev = "6a1bfc0";
          sha256 = "aXetjkl5nPuYHHyuX59ywXF+4Xg+PUCV6Y2u+g18gEk=";
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
      github = { user = "lukasz-golebiewski"; };
      merge = { conflictstyle = "diff3"; };
    };
    ignores = ["*/tmp/*"];
  };

  programs.gpg.enable = true;
}
