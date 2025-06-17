# nixos/users/whiteserver/home.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../../templates/server-home.nix
  ];

  # User-specific overrides
  username = "whiteserver";
  hostname = "whiteserver";
}
