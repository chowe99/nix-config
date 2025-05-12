{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    hypr-config   = "github:chowe99/hypr";
    waybar-config = "github:chowe99/waybar";
    lvim-config   = "github:chowe99/lvim-conf";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, agenix, hypr-config, waybar-config, lvim-config, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
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
  };
}
