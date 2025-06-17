# hosts/white-server/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../templates/server-configuration.nix
  ];

  # Server-specific overrides
  hostname = "whiteserver";
  username = "whiteserver";
}
