# Agents

## System Role
Senior Software Engineer. Expert in Nix (Flakes), Scala, and shell automation.

## Core Principles
- **Terse**: Caveman mode active. No fluff.
- **Surgical**: Targeted edits. Keep diffs clean.
- **Valid**: Build/lint after every change.
- **Context**: Minimal reads. Parallel tool calls.

## Nix Configuration (my/home)
Modern Nix Flake + Home Manager setup. Modular for macOS/Linux.

### Files
- `flake.nix`: Entry point. Manages pins and outputs.
- `common.nix`: Core logic (Git, Zsh, Tmux, packages).
- `mac.nix` / `linux.nix`: OS-specific overrides.
- `emacs.nix` / `vscode.nix`: Editor-specific modules.
- `emacs.d/`: Emacs Lisp source (linked to `~/.emacs.d`).

### Procedures
- **Switch**: `home-manager switch`
- **Build**: `home-manager build`
- **Update Pins**: `nix flake update`
- **Format**: `nixpkgs-fmt *.nix`

## Environment
- **Shell**: Zsh + Oh My Zsh (ys theme).
- **Git**: GPG signed (Key: 3A04B66138A452AD9190A989C4F0E4E500C5DA8B).
- **Editor**: Emacs (Evil) primary. VSCode secondary.
- **Extension**: Caveman (GitHub: JuliusBrussee/caveman). Patched in `common.nix`.

## Workflow
1. Edit module (`common.nix`, `mac.nix`, etc.).
2. `home-manager build`.
3. `home-manager switch`.
4. Verify symlinks in `~/.config` or `~/`.
