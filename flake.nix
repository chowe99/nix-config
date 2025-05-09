{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    # your channels
    nixpkgs.url       = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url                  = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pull in Hyprland as a flake
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
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

        # bring in the Home-Manager NixOS module
        home-manager.nixosModules.home-manager

        # configure the module to load your user’s home.nix
        {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;

          home-manager.users = {
            # must match users.users.<name> in your configuration.nix
            nix = {
              imports = [ ./nixos/users/nix/home.nix ];
            };
          };
        }
      ];
    };

    ### 2) standalone Home-Manager flake ###
    homeConfigurations."nix@<host>" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        # your existing home.nix (minus the programs.hyprland block)
        ./nixos/users/nix/home.nix

        # override only the hyprland bits from the flake:
        {
          wayland.windowManager.hyprland = {
            enable        = true;
            package       = hyprland.packages.${system}.hyprland;
            portalPackage = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
          };
        }
      ];
    };
  };
}
