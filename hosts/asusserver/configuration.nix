# hosts/asusserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix  # Include directly as a module
    ../../configs/k3s.nix
  ];

  services.k3s.role = "agent";
}
