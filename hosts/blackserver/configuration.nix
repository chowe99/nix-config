{ config, pkgs, inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../templates/server-configuration.nix
       ../../configs/k3s.nix
     ];

     services.k3s = {
       role = "server";
       tokenFile = "/run/agenix/k3s-token";
       extraFlags = toString [
         "--disable=traefik"
         "--server https://10.1.1.249:6443"
         "--advertise-address=10.1.1.250"
         "--node-ip=10.1.1.250"
         "--tls-san=10.1.1.250"
       ];
     };

     networking.firewall = {
       enable = true;
       allowedTCPPorts = [ 6443 2379 2380 10250 ];
       allowedUDPPorts = [ 8472 ];
     };

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
