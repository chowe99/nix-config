{ config, pkgs, inputs, username, ... }:
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
         # "--disable=traefik"
         "--server https://10.1.1.249:6443"
         # "--advertise-address=10.1.1.250"
         "--node-ip=10.1.1.250"
         "--node-name=blackserver"
         # "--tls-san=10.1.1.250"
         # "--tls-san=127.0.0.1"
       ];
     };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 52631 6443 2379 2380 10250 24007 24008 49152 49153 49154 ];
      allowedUDPPorts = [ 8472 24007 24008 ];
    };

     networking.hosts = {
       "10.1.1.249" = [ "whiteserver" ];
       "10.1.1.250" = [ "blackserver" ];
       "10.1.1.64" = [ "asusserver" ];
     };

     # fileSystems."/mnt/nas" = {
     #   device = "/dev/disk/by-uuid/e19aca63-e0cc-4e98-af16-4eb9000c55fc";
     #   fsType = "ext4";
     #   options = [ "defaults" ];
     # };

     systemd.tmpfiles.rules = [
       "d /mnt/nas/glusterfs/nextcloud 0755 ${username} root -"  # For whiteserver, blackserver
     ];

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
