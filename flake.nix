{
  description = "Lukasz's Multi-platform Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "x86_64-darwin" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

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
      # The "magic" for zero-argument home-manager commands on any machine.
      # home-manager automatically searches legacyPackages.${system}.homeConfigurations.${username}
      legacyPackages = forAllSystems (system: {
        homeConfigurations = {
          lukasz = mkHome system;
          runner = mkHome system; # For GitHub Actions
        };
      });

      # Explicit configurations for manual override or documentation
      homeConfigurations = {
        "lukasz@mac"   = mkHome "aarch64-darwin";
        "lukasz@linux" = mkHome "x86_64-linux";
      };

      # Standard packages output for CI/Nix tools
      packages = forAllSystems (system: {
        # Expose home-manager CLI for 'nix run'
        home-manager = home-manager.packages.${system}.home-manager;
        # Default build is the activation package
        default = self.legacyPackages.${system}.homeConfigurations.lukasz.activationPackage;
      });
    };
}
