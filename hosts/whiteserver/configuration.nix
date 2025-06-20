{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix
    ../../configs/caddy.nix
    ../../configs/docker.nix
    ../../configs/k3s.nix
  ];

}
