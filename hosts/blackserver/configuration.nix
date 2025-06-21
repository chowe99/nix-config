# hosts/blackserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix  # Include directly as a module
    ../../configs/k3s.nix
  ];

  services.k3s.role = "server";
  services.k3s.tokenFile = "/run/agenix/k3s-token";
  services.k3s.extraFlags = "--disable=traefik --cluster-init";
}
