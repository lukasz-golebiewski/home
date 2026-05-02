{
  description = "Lukasz's Multi-platform Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, emacs-overlay, ... }@inputs:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];

      # Helper to build the configuration
      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./common.nix
          # Dynamic OS module selection based on the system string
          (if nixpkgs.lib.hasInfix "darwin" system then ./mac.nix else ./linux.nix)
        ];
      };
    in {
      # home-manager looks for these at the top level
      homeConfigurations = {
        # Architecture-specific names that home-manager can auto-detect
        "lukasz@aarch64-darwin" = mkHome "aarch64-darwin";
        "lukasz@x86_64-linux"   = mkHome "x86_64-linux";

        # Friendly aliases
        "lukasz@mac"   = mkHome "aarch64-darwin";
        "lukasz@linux" = mkHome "x86_64-linux";
      };

      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        default = self.homeConfigurations."lukasz@${system}".activationPackage;
      });
    };
}
