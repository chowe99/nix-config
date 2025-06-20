{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix
    ../../configs/caddy.nix
    ../../configs/docker.nix
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--cluster-init";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 6443 2379 2380 24007 24008 49152 49153 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

}
