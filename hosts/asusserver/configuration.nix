{ config, pkgs, inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../templates/server-configuration.nix
       ../../configs/k3s.nix
     ];

     services.k3s = {
       role = "agent";
       serverAddr = "https://10.1.1.249:6443";
       tokenFile = "/run/agenix/k3s-token";
       extraFlags = toString [
         "--node-ip=10.1.1.64"
       ];
     };

     networking.firewall = {
       enable = true;
       allowedTCPPorts = [ 6443 10250 ];
       allowedUDPPorts = [ 8472 ];
     };

     networking.hosts = {
       "10.1.1.249" = [ "whiteserver" ];
       "10.1.1.250" = [ "blackserver" ];
     };

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
