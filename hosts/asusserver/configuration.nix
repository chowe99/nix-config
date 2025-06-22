# hosts/asusserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix  # Include directly as a module
    ../../configs/k3s.nix
  ];

  services.k3s = {
    role = "agent";
    serverAddr = "https://100.64.65.24:6443";  # whiteserver’s IP
      tokenFile = "/run/agenix/k3s-token";       # Same token as servers
  };
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;
}
