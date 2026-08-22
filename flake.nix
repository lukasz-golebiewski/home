{
  description = "Lukasz's Multi-platform Home Manager Configuration";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    in
    {
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
        "lukasz@mac" = mkHome "aarch64-darwin";
        "lukasz@linux" = mkHome "x86_64-linux";
      };

      # Standard packages output for CI/Nix tools
      packages = forAllSystems (system: {
        # Expose home-manager CLI for 'nix run'
        home-manager = home-manager.packages.${system}.home-manager;
        # Default build is the activation package
        default = self.legacyPackages.${system}.homeConfigurations.lukasz.activationPackage;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixSrc = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.fileFilter (file: file.hasExt "nix") ./.;
          };
          # Keep in sync with .statix.toml
          statixToml = pkgs.writeText "statix.toml" ''
            disabled = ["repeated_keys"]
          '';
        in
        {
          formatting = pkgs.runCommand "formatting-check"
            {
              nativeBuildInputs = [ pkgs.nixpkgs-fmt ];
            } ''
            nixpkgs-fmt --check ${nixSrc}
            touch $out
          '';
          statix = pkgs.runCommand "statix-check"
            {
              nativeBuildInputs = [ pkgs.statix ];
            } ''
            statix check -c ${statixToml} ${nixSrc}
            touch $out
          '';
          deadnix = pkgs.runCommand "deadnix-check"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            } ''
            deadnix --fail ${nixSrc}
            touch $out
          '';
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixpkgs-fmt
              pkgs.statix
              pkgs.deadnix
            ];
          };
        });
    };
}
