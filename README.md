## Installation
Clone the repo to `~/git/my/` and then:
`$ ln -s ~/git/my/home ~/.config/nixpkgs`

Afterwards, in the repo root dir, create a `home.nix` link to the OS-specific config:
`ln -s linux.nix home.nix`

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
