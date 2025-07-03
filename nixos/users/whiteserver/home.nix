# nixos/users/whiteserver/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    # inputs.nixvim.homeManagerModules.nixvim
    # ../../../configs/nixvim.nix
    ../../../templates/server-home.nix  # Include directly as a module
  ];
}
