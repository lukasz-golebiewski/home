## Installation
Clone the repo to `~/git/my/` and then:
`$ ln -s ~/git/my/home ~/.config/home-manager`

Afterwards, in the repo root dir, create a `home.nix` link to the OS-specific config:
`ln -s linux.nix home.nix`

NOTE: Use the latest stable channel, e.g. on a mac use:
```
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixpkgs-25.05-darwin nixpkgs
```

Do:
https://nix-community.github.io/home-manager/index.html#sec-install-standalone

## Usage:
https://nix-community.github.io/home-manager/index.html#ch-usage

```
home-manager build
```
Switch to a new configuration after modifying home.nix
```
home-manager switch
```
