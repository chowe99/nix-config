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
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    nixosSystem = { system, hostname, username, modules }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { 
        inherit inputs; 
        inherit hostname username; 
      };
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
        inherit system;
        hostname = "nix";
        username = "nix";
        modules = [
          ./hosts/nix/configuration.nix
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            environment.systemPackages = with pkgs; [
              inputs.agenix.packages.${system}.default
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nix = import ./nixos/users/nix/home.nix;
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
            home-manager.users.whiteserver = import ./nixos/users/whiteserver/home.nix;
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
            home-manager.users.blackserver = import ./nixos/users/blackserver/home.nix;
            home-manager.extraSpecialArgs = { 
              inherit inputs; 
              hostname = "blackserver"; 
              username = "blackserver"; 
            };
          }
        ];
      };
    };

    homeConfigurations = {
      cod = homeManagerConfig {
        username = "cod";
        system = "aarch64-linux";
        modules = [
          # Note: nix-flatpak is not in inputs, so this line is commented out to avoid errors
          # nix-flatpak.homeManagerModules.nix-flatpak
          ./nixos/users/cod/home.nix
        ];
      };
    };
  };
}
