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

     fileSystems."/mnt/nas" = {
       device = "/dev/disk/by-uuid/50c0aea4-ebb4-4e24-8ddc-4f8df5bf3323";
       fsType = "ext4";
       options = [ "defaults" ];
     };

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
