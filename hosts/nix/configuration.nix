# hosts/nixos/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/user-configuration.nix  # Include directly as a module
  ];
}
