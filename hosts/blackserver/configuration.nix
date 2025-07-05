{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
      ../../templates/server-configuration.nix
      ../../configs/k3s.nix
      ../../configs/docker.nix
      # ../../configs/glusterfs-mount.nix
  ];

  environment.systemPackages = with pkgs; [
    nodejs_24
    yarn
    bash
  ];

  systemd.services.keebs = {
    description = "Keebs Next.js Application";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash /home/blackserver/keebs/start-keebs.sh";
      WorkingDirectory = "/home/blackserver/keebs/";
      Restart = "always";
      RestartSec = "5s";
      Environment = [
        "PORT=3008"
        "NODE_ENV=development"
      ];
      User = "blackserver";
      Group = "users";
    };
  };

#   services.k3s = {
#     role = "server";
#     tokenFile = "/run/agenix/k3s-token";
#     extraFlags = toString [
#       "--disable=traefik"
#       "--server https://10.1.1.249:6443"
# # "--advertise-address=10.1.1.250"
#         "--node-ip=10.1.1.250"
#         "--node-name=blackserver"
# # "--tls-san=10.1.1.250"
# # "--tls-san=127.0.0.1"
#     ];
#   };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = "/run/agenix/k3s-token";
    extraFlags = toString [
      "--server https://10.1.1.64:6443"  # Point to asusserver
      "--node-ip=10.1.1.250"
    ];
  };

  users.users.git = {
    isSystemUser = true;  # Marks git as a system user (no login shell by default)
      uid = 998;           # Specify the UID
      group = "git";       # Assign to a group named "git"
      description = "GitLab user";
  };

  users.groups.git = {
    gid = 998;  # Specify the GID to match UID
  };

  virtualisation.oci-containers.containers = {
    gitlab = {
      image = "gitlab/gitlab-ce:latest";
      hostname = "git.howse.top";
      ports = [
        "1480:80"
          "2222:22"
      ];
      volumes = [
        "/mnt/nas/gitlab/config:/etc/gitlab"
          "/mnt/nas/gitlab/logs:/var/log/gitlab"
          "/mnt/nas/gitlab/data:/var/opt/gitlab"
      ];
      extraOptions = [
        "--network=server_network"
      ];
      autoStart = true;
    };
  };

networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 3008 8080 11000 1480 52631 6443 2379 2380 10250 24007 24008 49152 49153 49154 ];
  allowedUDPPorts = [ 8472 24007 24008 ];
};

  networking.hosts = {
    "10.1.1.249" = [ "whiteserver" ];
    "10.1.1.250" = [ "blackserver" ];
    "10.1.1.64" = [ "asusserver" ];
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

  systemd.tmpfiles.rules = [
    "d /mnt/nas/glusterfs/nextcloud 0755 ${username} root -"  # For whiteserver, blackserver
  ];

  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
}
