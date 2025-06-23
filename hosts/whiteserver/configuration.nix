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
       tokenFile = "/run/agenix/k3s-token";
       extraFlags = toString [
         "--disable=traefik"
         "--cluster-init"
         "--advertise-address=10.1.1.249"
         "--node-ip=10.1.1.249"
         "--tls-san=10.1.1.249"
       ];
     };

     networking.firewall = {
       enable = true;
       allowedTCPPorts = [ 6443 2379 2380 10250 ];
       allowedUDPPorts = [ 8472 ];
     };

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
