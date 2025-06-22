# hosts/blackserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      ../../templates/server-configuration.nix  # Include directly as a module
      ../../configs/k3s.nix
  ];

  services.k3s = {
    role = "server";
    tokenFile = "/run/agenix/k3s-token";  # Shared secret for cluster joining
      extraFlags = toString [
      "--disable=traefik"  # Disable Traefik ingress (you’re using Caddy)
        "--server https://100.64.65.24:6443" # Join whiteserver’s cluster

      ];
  };

# Ensure the token file is accessible (assuming agenix is set up)
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
}
