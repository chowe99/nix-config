{
  description = "Flake-based NixOS + Home Manager config";

  inputs = {
    # your channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pull in Hyprland as a flake
    hyprland.url = "github:hyprwm/Hyprland";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

  };

#   sddmAstronautThemePkg = pkgs.stdenv.mkDerivation {
#     pname = "sddm-astronaut-theme";
#     version = sddm-astronaut-theme-src.lastModifiedDate or "master";
#     src = sddm-astronaut-theme-src;

#     installPhase = ''
# # ... (copying files to $out/share/sddm/themes/sddm-astronaut-theme) ...
# # ... (modifying metadata.desktop to select hyprland_kath.conf) ...
# # ... (installing fonts) ...
#       '';
# # ...
#   };


  outputs = { self, nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
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
          home-manager.backupFileExtension = "bak"; # Automatically back up conflicting files"""
        }
      ];
    };

    ### 2) standalone Home-Manager flake ###
    homeConfigurations."nix@nixos" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        # your existing home.nix (minus the programs.hyprland block)
        ./nixos/users/nix/home.nix

        # override only the hyprland bits from the flake:
        {
          wayland.windowManager.hyprland = {
            enable        = true;
            # package       = pkgs.hyprland;
            # portalPackage = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
            extraConfig = (builtins.readFile /home/nix/nix-config/nixos/users/nix/hyprland.conf);
          };
        }
      ];
    };
  };
}
