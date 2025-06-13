{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dotfiles = {
      url = "github:chowe99/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, nix-flatpak, nixvim, ... }@inputs:
  let
    nixosSystem = { system, modules }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      inherit modules;
    };

    homeManagerConfig = { username, system, modules }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      inherit modules;
    };
  in {
    nixosConfigurations = {
      nix = nixosSystem {
        system = "x86_64-linux";
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

      server = nixosSystem {
        system = "x86_64-linux";
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
      cod = homeManagerConfig {
        username = "cod";
        system = "aarch64-linux";
        modules = [
          nix-flatpak.homeManagerModules.nix-flatpak
          ./nixos/users/cod/home.nix
        ];
      };
      nix = homeManagerConfig {
        username = "nix";
        system = "x86_64-linux";
        modules = [
          nix-flatpak.homeManagerModules.nix-flatpak
          ./nixos/users/nix/home.nix
        ];
      };
    };
  };
}
