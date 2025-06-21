# hosts/blackserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix  # Include directly as a module
    ../../configs/k3s.nix
  ];

  services.k3s.role = "server";
  services.k3s.serverAddr = "https://100.64.65.24:6443";
  services.k3s.tokenFile = "/run/agenix/k3s-token";
  servics.k3s.extraFlags = "--disable=traefik --cluster-init"
}
