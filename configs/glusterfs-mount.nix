# GlusterFS mount configuration for Nextcloud data directory
{ config, pkgs, ... }:

{
  # Ensure the GlusterFS client package is installed
  environment.systemPackages = with pkgs; [
    glusterfs
  ];

  # Create the mount directory if it doesn't exist
  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud/data 0750 nextcloud nextcloud - -"
  ];

  # Configure the mount in fstab
  fileSystems."/var/lib/nextcloud/data" = {
    device = "localhost:/nextcloud-vol";
    fsType = "glusterfs";
    options = [
      "defaults"
      "acl"
      "_netdev"
      "backupvolfile-server=localhost"
      "log-level=WARNING"
      "log-file=/var/log/gluster.log"
    ];
  };
}

