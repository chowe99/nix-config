{ config, pkgs, inputs, username, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../templates/server-configuration.nix
       ../../configs/k3s.nix
      ../../configs/glusterfs-mount.nix
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
      allowedTCPPorts = [ 50773 6443 10250 24007 24008 49152 49153 49154 ];
      allowedUDPPorts = [ 8472 24007 24008 ];
    };

     networking.hosts = {
       "10.1.1.249" = [ "whiteserver" ];
       "10.1.1.250" = [ "blackserver" ];
       "10.1.1.64" = [ "asusserver" ];
     };

     fileSystems."/mnt/nas" = {
       device = "/dev/disk/by-uuid/520ba2d7-6a80-4fcf-b5c8-ef8887588438";
       fsType = "ext4";
       options = [ "defaults" ];
     };

     systemd.tmpfiles.rules = [
         "d /mnt/nas/glusterfs/nextcloud_arbiter 0755 ${username} root -"  # For asusserver
     ];

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
