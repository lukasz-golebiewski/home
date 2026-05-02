{
  description = "Lukasz's Dynamic Home Manager Configuration";

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
      # Detect current system architecture and OS
      system = builtins.currentSystem;
      
      # Helper to build the configuration
      mkHome = sys: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${sys};
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
          (if nixpkgs.lib.hasInfix "darwin" sys then ./mac.nix else ./linux.nix)
        ];
      };
    in {
      homeConfigurations = {
        # This will work on any machine with username 'lukasz' 
        # because 'system' is detected at runtime.
        "lukasz" = mkHome system;
        
        # Explicit versions just in case you need to build for another target
        "lukasz@mac" = mkHome "aarch64-darwin";
        "lukasz@linux" = mkHome "x86_64-linux";
      };
    };
}
