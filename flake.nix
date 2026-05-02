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
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "x86_64-darwin" "aarch64-linux" ];
      
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
          # Dynamic OS module selection
          (if nixpkgs.lib.hasInfix "darwin" system then ./mac.nix else ./linux.nix)
        ];
      };

      # Generate all configs in a separate let binding to avoid circular references
      allConfigs = nixpkgs.lib.genAttrs supportedSystems (system: mkHome system);

      # Detect current system for the 'lukasz' alias
      currentSystem = builtins.currentSystem or "aarch64-darwin";
    in {
      homeConfigurations = allConfigs // {
        # This is the "magic" entry for zero-argument home-manager commands
        "lukasz" = allConfigs."${currentSystem}" or allConfigs."aarch64-darwin";
        
        # GitHub Actions runner
        "runner" = allConfigs."x86_64-linux";

        # Friendly aliases
        "lukasz@mac"   = allConfigs."aarch64-darwin";
        "lukasz@linux" = allConfigs."x86_64-linux";
      };

      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        # Expose home-manager CLI for 'nix run'
        home-manager = home-manager.packages.${system}.home-manager;
        # Standard default build
        default = allConfigs."${system}".activationPackage;
      });
    };
}
