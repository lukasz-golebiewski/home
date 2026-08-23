# Lukasz's Home Manager Configuration

Modern [Home Manager](https://github.com/nix-community/home-manager) setup using Nix Flakes.

## Quick Start

### Apply Changes
```bash
home-manager switch
```

### Dry Run
```bash
home-manager build
```

## Structure

- **`flake.nix`**: Dependency management and system outputs.
- **`common.nix`**: Core packages, Zsh, Tmux, and Git configuration.
- **`mac.nix` / `linux.nix`**: OS-specific settings.
- **`emacs.nix` / `vscode.nix`**: Editor configurations.
- **`emacs.d/`**: Source for `~/.emacs.d`.
- **`AGENTS.md`**: Instruction manual for AI agents (Gemini/Claude).

## Maintenance

Update flake inputs:
```bash
nix flake update
```

Format and lint (CI runs `nix flake check` on PRs and on `main`/`master`):
```bash
nix fmt
nix flake check --print-build-logs
```

`nix flake check` covers nixpkgs-fmt, statix, deadnix, and `elisp-byte-compile` (`emacs.d/**/*.el`). Syntax errors fail; warnings do not.

Elisp only (installed Emacs; any system):
```bash
emacs --batch -Q -f batch-byte-compile emacs.d/init.el emacs.d/config/*.el
```

Same check through the flake, for the system you are on:
```bash
nix build --print-build-logs .#checks.$(nix eval --impure --raw --expr builtins.currentSystem).elisp-byte-compile
```

## AI Agents
This repo contains `GEMINI.md`, `CLAUDE.md`, `GROK.md`, and `AGENTS.md` to provide context for AI coding assistants.
