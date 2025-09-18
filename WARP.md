# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a Nix Home Manager configuration repository that manages cross-platform dotfiles and development environment setup. It uses a modular architecture to support both macOS and Linux environments while sharing common configurations.

## Essential Commands

### Home Manager Operations
```bash
# Build configuration without switching (dry run)
home-manager build

# Apply new configuration
home-manager switch

# Check what would change
home-manager build --show-trace
```

### Development Workflow
```bash
# Format Nix files
nixpkgs-fmt *.nix

# Check Nix syntax
nix-instantiate --parse <file>.nix

# Test configuration on current system
home-manager switch --dry-run
```

### System Setup (One-time)
```bash
# Create Home Manager symlink (from repo root)
ln -s ~/git/my/home ~/.config/home-manager

# Link OS-specific config (choose one)
ln -s linux.nix home.nix    # For Linux
ln -s mac.nix home.nix      # For macOS (already done)

# Add Nix channels (macOS example)
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixpkgs-25.05-darwin nixpkgs
nix-channel --update
```

## Architecture

### Configuration Structure
- **`common.nix`**: Core configuration shared across all platforms
  - Package definitions, programs, and base settings
  - VSCode, Git, Zsh, Tmux, and Emacs configurations
- **`mac.nix`**: macOS-specific overrides and packages
- **`linux.nix`**: Linux-specific overrides and packages
- **`emacs.nix`**: Dedicated Emacs configuration with overlay
- **`emacs.d/`**: Emacs Lisp configuration files
- **`home.nix`**: Symlink to platform-specific entry point

### Key Technologies
- **Nix**: Functional package manager and configuration language
- **Home Manager**: Nix-based dotfiles and user environment management
- **Emacs**: Primary editor with extensive package configuration
- **Zsh**: Shell with Oh My Zsh, plugins, and custom aliases
- **Tmux**: Terminal multiplexer with plugins
- **VSCode**: Secondary editor with Vim bindings and language support

### Platform Differences
- macOS includes specific packages like `libiconv`, `watch`, `ntfs3g`
- Linux includes multimedia packages like `vlc`, `mplayer`, `peek`
- Both inherit from `common.nix` for shared functionality

## Development Environment

### Supported Languages & Tools
- **Scala**: SBT, Metals LSP, VS Code extensions
- **Nix**: Language server (nil), formatting (nixpkgs-fmt)
- **TypeScript/JavaScript**: Language server, React support
- **Rust**: Rust analyzer, cargo integration
- **Haskell**: LSP support, language mode
- **Docker/Kubernetes**: kubectl, helm, k9s, docker support

### Editor Configuration
- Primary: Emacs with Evil mode (Vim bindings)
- Secondary: VSCode with Vim extension
- Both configured with consistent keybindings and themes

## Shell Environment

### Zsh Features
- Oh My Zsh with `ys` theme
- Custom aliases (e.g., `k` for `kubectl`)
- Advanced plugins: you-should-use, history search, z navigation
- Direnv integration for project environments
- `emacsclient` as default `$EDITOR`

### Key Aliases
- `k`: kubectl
- `du.`: disk usage for current directory
- Custom ffmpeg/video encoding functions

## Git Configuration

- Signed commits enabled (GPG key: 3A04B66138A452AD9190A989C4F0E4E500C5DA8B)
- GitHub integration configured
- Conflict style: diff3
- Global ignore: `*/tmp/*`

## Package Management

All packages are declaratively managed through Nix. Key development tools include:
- Cloud: `awscli2`, `google-cloud-sdk`, `kubectl`, `helm`
- Development: Language servers, formatters, build tools
- Media: `ffmpeg`, video codecs
- Utilities: `jq`, `htop`, `ag` (silver-searcher)

## Configuration Modification Workflow

1. Edit relevant `.nix` files
2. Test with `home-manager build`
3. Apply with `home-manager switch`
4. Commit changes to Git
5. For cross-platform changes, test on both macOS and Linux if possible

## Troubleshooting

### Common Issues
- Channel version mismatches: Ensure channels are updated
- Build failures: Check `--show-trace` output
- Missing packages: Verify nixpkgs version compatibility
- Emacs packages: Check overlay version and package availability

### Reset Operations
```bash
# Rollback to previous generation
home-manager generations
home-manager switch --rollback

# Clean up old generations
nix-collect-garbage -d
```