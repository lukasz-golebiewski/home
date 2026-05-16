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

Format code:
```bash
nixpkgs-fmt *.nix
```

## AI Agents
This repo contains `GEMINI.md`, `CLAUDE.md`, and `AGENTS.md` to provide context for AI coding assistants.
