# Lukasz's Home Manager Configuration

This directory contains my [Home Manager](https://github.com/nix-community/home-manager) configuration, now modernized using Nix Flakes.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/lukasz-golebiewski/git.git ~/git
    cd ~/git/my/home
    ```

2.  **Apply the configuration:**
    Use the configuration specific to your system:
    
    **For macOS:**
    ```bash
    nix run home-manager/release-25.05 -- switch --flake .#lukasz@mac
    ```
    
    **For Linux:**
    ```bash
    nix run home-manager/release-25.05 -- switch --flake .#lukasz@linux
    ```

## Usage

After the initial installation, you can use the `home-manager` command directly:

```bash
# Switch to updated configuration
home-manager switch --flake .#lukasz@mac

# Build without applying
home-manager build --flake .#lukasz@mac
```

### Structure

- `flake.nix`: Entry point and dependency management (pins nixpkgs and overlays).
- `common.nix`: Shared packages and configuration (Zsh, Tmux, Git, etc.).
- `mac.nix` / `linux.nix`: OS-specific packages and settings.
- `emacs.nix`: Emacs configuration with `emacs-overlay`.
- `vscode.nix`: VS Code profiles and extensions.
- `emacs.d/`: Emacs initialization files (linked to `~/.emacs.d`).

## Maintenance

To update dependencies (pins):
```bash
nix flake update
```
