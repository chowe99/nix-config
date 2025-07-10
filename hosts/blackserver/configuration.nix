{ config, pkgs, inputs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
      ../../templates/server-configuration.nix
      ../../configs/k3s.nix
      ../../configs/docker.nix
      ../../configs/ollama.nix
      ../../configs/nvidia.nix
      ../../configs/stable-diffusion.nix
      # ../../configs/glusterfs-mount.nix
  ];
  nixpkgs.config.allowUnfree = true;

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


networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 
    7860 # Stable Diffusion WebUI
    8080 
    11000 
    52631 
    6443 
    2379 
    2380 
    10250 
    24007 
    24008 
    49152 
    49153 
    49154 
  ];
  allowedUDPPorts = [ 
    8472 
    24007 
    24008 
  ];
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
