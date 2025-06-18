# hosts/whiteserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../../templates/server-configuration.nix { inherit inputs pkgs; hostname = "whiteserver"; username = "whiteserver"; })
  ];
}
