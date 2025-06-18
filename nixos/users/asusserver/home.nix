# nixos/users/asusserver/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    ../../../templates/server-home.nix  # Include directly as a module
  ];
}
