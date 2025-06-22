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

  services.k3s = {
    role = "server";
    tokenFile = "/run/agenix/k3s-token";  # Shared secret for cluster joining
      extraFlags = toString [
      "--disable=traefik"  # Disable Traefik ingress (you’re using Caddy)
        "--cluster-init"     # Initialize the cluster (only needed on the first server)
      ];
  };
# Ensure the token file is accessible (assuming agenix is set up)
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
}
