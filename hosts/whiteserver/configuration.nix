{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
      ../../templates/server-configuration.nix
      ../../configs/caddy.nix
      ../../configs/docker.nix
      ../../configs/k3s.nix
      # (import ../../configs/nixvim.nix { inherit inputs; })
  ];

  # services.k3s = {
  #   role = "server";
  #   tokenFile = "/run/agenix/k3s-token";
  #   extraFlags = toString [
  #     "--disable=traefik"
  #       "--cluster-init"
  #       "--advertise-address=10.1.1.249"
  #       "--node-ip=10.1.1.249"
  #       "--node-name=whiteserver"
  #       # "--tls-san=10.1.1.249"
  #       # "--tls-san=127.0.0.1"
  #       # "--tls-san=k3s.howse.top"
  #       # "--tls-san=dashboad.howse.top"
  #   ];
  # };


  fileSystems."/mnt/nas" = {
    device = "/dev/disk/by-uuid/e19aca63-e0cc-4e98-af16-4eb9000c55fc";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 55028 6443 2379 2380 10250 24007 24008 49152 49153 49154 ];
  #   allowedUDPPorts = [ 8472 24007 24008 ];
  # };
  networking.hosts = {
    "10.1.1.250" = [ "blackserver" ];
    "10.1.1.249" = [ "whiteserver" ];
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
          ${pkgs.glusterfs}/bin/gluster volume create nextcloud-vol replica 3 arbiter 1 \
            whiteserver:/mnt/nas/glusterfs/nextcloud \
            blackserver:/mnt/nas/glusterfs/nextcloud \
            asusserver:/mnt/nas/glusterfs/nextcloud_arbiter
            ${pkgs.glusterfs}/bin/gluster volume start nextcloud-vol
            fi
            ''}/bin/glusterfs-volume-setup";
    RemainAfterExit = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/nas/glusterfs/nextcloud 0755 ${username} root -"  # For whiteserver, blackserver
  ];

  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
}
