# nixos/users/whiteserver/home.nix
{ inputs, pkgs, ... }:

{
  imports = [
    (import ../../../templates/server-home.nix { inherit inputs pkgs; username = "whiteserver"; hostname = "whiteserver"; })
  ];
}
