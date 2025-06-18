{ description = "Flake-based NixOS + Home Manager config";

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

outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, nix-flatpak, nixvim, ... }@inputs: let
  systems = [ "x86_64-linux" "aarch64-linux" ];
  mkNixOS = host: nixpkgs.lib.nixosSystem {
    system = host.system;
    specialArgs = { inherit inputs; hostname = host.name; username = host.user; };
    modules = [
      ./hosts/${host.name}/configuration.nix
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      # Minimal system-specific only
    ];
  };
  hosts = [
    { name = "nix"; system = "x86_64-linux"; user = "nix"; }
    { name = "whiteserver"; system = "x86_64-linux"; user = "whiteserver"; }
    { name = "blackserver"; system = "x86_64-linux"; user = "blackserver"; }
  ];
in {
  nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
    name = host.name;
    value = mkNixOS host;
  }) hosts);

  homeConfigurations = {
    # cod user on aarch64
    cod = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = { inherit inputs; hostname = "cod"; username = "cod"; };
      modules = [
        nix-flatpak.homeManagerModules.nix-flatpak
        nixvim.homeManagerModules.nixvim
        ./nixos/users/cod/home.nix
      ];
    };

    # other x86 users
    nix = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; hostname = "nix"; username = "nix"; };
      modules = [
        nix-flatpak.homeManagerModules.nix-flatpak
        nixvim.homeManagerModules.nixvim
        ./nixos/users/nix/home.nix
      ];
    };

    whiteserver = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; hostname = "whiteserver"; username = "whiteserver"; };
      modules = [
        nix-flatpak.homeManagerModules.nix-flatpak
        nixvim.homeManagerModules.nixvim
        ./nixos/users/whiteserver/home.nix
      ];
    };

    blackserver = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; hostname = "blackserver"; username = "blackserver"; };
      modules = [
        nix-flatpak.homeManagerModules.nix-flatpak
        nixvim.homeManagerModules.nixvim
        ./nixos/users/blackserver/home.nix
      ];
    };
  };
}

