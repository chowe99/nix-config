{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
# nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dotfiles = {
      url = "github:chowe99/dotfiles";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim/";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
    let
    system = "x86_64-linux";
  pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

  nixosSystem = { system, hostname, username, modules }: nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { 
      inherit inputs; 
      inherit hostname username; 
    };
    inherit modules;
  };

  homeManagerConfig = { username, system, hostname, modules }: home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
    extraSpecialArgs = { 
      inherit inputs; 
      inherit username hostname; 
    };
    inherit modules;
  };

  in {
    nixosConfigurations = {
      nix = nixosSystem {
        inherit system;
        hostname = "nix";
        username = "nix";
        modules = [
          ./hosts/lemur/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nix = import ./users/nix/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs; 
                hostname = "nix"; 
                username = "nix"; 
              };
            }
        ];
      };

      whiteserver = nixosSystem {
        inherit system;
        hostname = "whiteserver";
        username = "whiteserver";
        modules = [
          ./hosts/whiteserver/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.whiteserver = import ./users/whiteserver/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs; 
                hostname = "whiteserver"; 
                username = "whiteserver"; 
              };
            }
        ];
      };

      blackserver = nixosSystem {
        inherit system;
        hostname = "blackserver";
        username = "blackserver";
        modules = [
          ./hosts/blackserver/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blackserver = import ./users/blackserver/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs; 
                hostname = "blackserver"; 
                username = "blackserver"; 
              };
            }
        ];
      };

      asusserver = nixosSystem {
        inherit system;
        hostname = "asusserver";
        username = "asusserver";
        modules = [
          ./hosts/asusserver/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.asusserver = import ./users/asusserver/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs; 
                hostname = "asusserver"; 
                username = "asusserver"; 
              };
            }
        ];
      };
    };

    homeConfigurations = {
      cod = homeManagerConfig {
        username = "cod";
        system = "aarch64-linux";
        hostname = "cod";
        modules = [
# Note: nix-flatpak is not in inputs, so this line is commented out to avoid errors
# nix-flatpak.homeManagerModules.nix-flatpak
          ./users/cod/home.nix
        ];
      };
    };
  };
}
