{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:chowe99/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
  let
    # NixOS systems (x86_64-linux)
    nixosSystem = system: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
    };

    # Home Manager configuration for cod user (aarch64-linux)
    homeManagerConfig = username: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
    };
  in {
    nixosConfigurations = {
      nix = nixosSystem "x86_64-linux" {
        modules = [
          ./hosts/nixos/hardware-configuration.nix
          ./hosts/nixos/configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
              inputs.agenix.packages.${system}.default
            ];
          }
        ];
      };

      server = nixosSystem "x86_64-linux" {
        modules = [
          ./hosts/nixos-server/hardware-configuration.nix
          ./hosts/nixos-server/configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
              inputs.agenix.packages.${system}.default
            ];
          }
        ];
      };
    };

    homeConfigurations = {
      cod = homeManagerConfig "cod" "aarch64-linux" {
        modules = [
          ./nixos/users/cod/home.nix
        ];
      };
    };
  };
}
