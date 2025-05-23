{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # make sure HM uses the same nixpkgs
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
      nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/hardware-configuration.nix
          ./hosts/nixos/configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = with pkgs; [
              inputs.agenix.packages.${system}.default
            ];
          }
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
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
    };
  };
}
