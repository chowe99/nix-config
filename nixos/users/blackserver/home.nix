# nixos/users/whiteserver/home.nix
# nixos/users/whiteserver/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    ../../../templates/server-home.nix  # Include directly as a module
  ];
}
