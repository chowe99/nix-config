# ~/nix-config/nix/users/nix/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    ../../../templates/user-home.nix  # Include directly as a module
  ];
}
