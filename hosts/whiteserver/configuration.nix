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
         "--tls-san=127.0.0.1"
       ];
     };

     boot.swraid.enable = true;
     boot.swraid.mdadmConf = ''
       ARRAY /dev/md127 UUID=e22f6488:83684aca:f30ec314:f49242d1
       MAILADDR c0dred@tutamail.com
       '';

# Filesystem configuration for RAID
     fileSystems."/mnt/nas" = {
       device = "/dev/md127";
       fsType = "ext4";
       options = [ "defaults" "nofail" ];
     };

     networking.firewall = {
       enable = true;
       allowedTCPPorts = [ 6443 2379 2380 10250 ];
       allowedUDPPorts = [ 8472 ];
     };
      networking.hosts = {
        "10.1.1.250" = [ "blackserver" ];
        "10.1.1.64" = [ "asusserver" ];
      };

# GlusterFS Volume Setup
  systemd.services.glusterfs-volume-setup = {
    description = "GlusterFS Volume Setup for Nextcloud";
    after = [ "glusterd.service" "glusterfs-peer-probe.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScriptBin "glusterfs-volume-setup" ''
        #!/bin/sh
        if ! ${pkgs.glusterfs}/bin/gluster volume info nextcloud-vol > /dev/null 2>&1; then
          ${pkgs.glusterfs}/bin/gluster volume create nextcloud-vol replica 3 \
            10.1.1.249:/var/lib/glusterfs/nextcloud \
            10.1.1.250:/var/lib/glusterfs/nextcloud \
            10.1.1.64:/var/lib/glusterfs/nextcloud force
          ${pkgs.glusterfs}/bin/gluster volume start nextcloud-vol
        fi
      ''}/bin/glusterfs-volume-setup";
      RemainAfterExit = true;
    };
  };

     age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
   }
