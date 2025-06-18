# hosts/white-server/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../../templates/server-configuration.nix { inherit inputs; hostname = "whiteserver"; username = "whiteserver"; })
  ];
}
