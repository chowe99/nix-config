{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "github:hyprwm/Hyprland";

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
  in {
    nixosConfigurations = {
      # nix = nixpkgs.lib.nixosSystem {
      #   inherit system;
      #   specialArgs = { inherit inputs pkgs; }; # Add pkgs here
      #   modules = [
      #     ./hosts/nixos/hardware-configuration.nix
      #     ./hosts/nixos/configuration.nix
      #     agenix.nixosModules.default
      #     {
      #       environment.systemPackages = with pkgs; [
      #         inputs.agenix.packages.${system}.default
      #       ];
      #     }
      #   ];
      # };

      nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
          hostname = "nix"; 
          username = "nix"; 
        };
        modules = [
          ./hosts/nixos/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager  # Ensure Home Manager is included
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
# Home Manager configuration
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.whiteserver = import ./nixos/users/nix/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs; 
                hostname = "nix"; 
                username = "nix"; 
              };
            }
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs; }; # Add pkgs here
        modules = [
          ./hosts/nixos-server/hardware-configuration.nix
          ./hosts/nixos-server/configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = with pkgs; [
              inputs.agenix.packages.${system}.default
            ];
          }
        ];
      };

      whiteserver = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
          hostname = "whiteserver"; 
          username = "whiteserver"; 
        };
        modules = [
          ./hosts/whiteserver/configuration.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager  # Ensure Home Manager is included
            {
              environment.systemPackages = with pkgs; [
                inputs.agenix.packages.${system}.default
              ];
# Home Manager configuration
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

    };
  };
}
