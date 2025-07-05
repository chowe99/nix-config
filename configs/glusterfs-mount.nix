# GlusterFS mount configuration for Nextcloud data directory
{ config, pkgs, ... }:

{
  # Ensure the GlusterFS client package is installed
  environment.systemPackages = with pkgs; [
    glusterfs
  ];

  users.users.nextcloud = {
    isSystemUser = true;
    group = "nextcloud";
  };
  users.groups.nextcloud = {};

  # Create the mount directory if it doesn't exist
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/nextcloud/data 0750 nextcloud nextcloud - -"
  # ];

  # # Configure the mount in fstab
  # fileSystems."/var/lib/nextcloud/data" = {
  #   device = "10.1.1.249:/nextcloud-vol";  # Use whiteserver IP
  #   fsType = "glusterfs";
  #   options = [
  #     "defaults"
  #     "acl"
  #     "_netdev"
  #     # "backupvolfile-server=10.1.1.250"  # Use blackserver as backup
  #     "log-level=WARNING"
  #     "log-file=/var/log/gluster.log"
  #   ];
  # };

  # systemd.mounts = [
  #   {
  #     what = "10.1.1.249:/nextcloud-vol";
  #     where = "/var/lib/nextcloud/data";
  #     type = "glusterfs";
  #     options = "defaults,acl,_netdev,log-level=WARNING,log-file=/var/log/gluster.log";
  #   }
  # ];
}

