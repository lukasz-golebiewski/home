{ pkgs, ... }:

{
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
                "command" = [ "nixpkgs-fmt" ];
              };
            };
          };
          "vim.leader" = "<space>";
          "vim.normalModeKeyBindingsNonRecursive" = [
            {
              before = [ "<leader>" "l" "f" "d" ];
              commands = [ "editor.action.revealDefinition" ];
            }
            {
              before = [ "<leader>" "x" "c" ];
              commands = [ "workbench.action.showCommands" ];
            }
            {
              before = [ "<leader>" "x" "o" ];
              commands = [ "workbench.action.nextEditor" ];
            }
            {
              before = [ "<leader>" "x" "p" ];
              commands = [ "workbench.action.previousEditor" ];
            }
            {
              before = [ "<leader>" "x" "q" ];
              commands = [ "workbench.action.quit" ];
            }
            {
              before = [ "<leader>" "s" ];
              commands = [ "workbench.action.files.save" ];
            }
            {
              before = [ "<leader>" "g" "s" ];
              commands = [ "magit.status" ];
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
}
