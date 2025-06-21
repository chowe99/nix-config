# hosts/blackserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix
    ../../configs/caddy.nix
    ../../configs/docker.nix
    ../../configs/k3s.nix
  ];

  services.k3s.role = "server";
  services.k3s.tokenFile = "/run/agenix/k3s-token";
  servics.k3s.extraFlags = "--disable=traefik --cluster-init";
}
