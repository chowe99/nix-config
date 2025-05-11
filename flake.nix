{
  description = "Flake-based NixOS";

  inputs = {
    # your channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # pull in Hyprland as a flake
    hyprland.url = "github:hyprwm/Hyprland";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, hyprland, agenix, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
  in {
    ### 1) your NixOS system ###
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/nixos/hardware-configuration.nix
        ./hosts/nixos/configuration.nix
        agenix.nixosModules.default

        # Add agenix to environment.systemPackages
        {
          environment.systemPackages = with pkgs; [
            inputs.agenix.packages.${system}.default # Add agenix CLI tool
          ];
        }
      ];
    };

  };
}
