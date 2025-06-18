# ~/nix-config/nix/users/nix/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../../configs/nixvim.nix
    ../../../templates/user-home.nix  # Include directly as a module
  ];
}
