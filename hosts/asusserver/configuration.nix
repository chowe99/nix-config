# hosts/asusserver/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/server-configuration.nix  # Include directly as a module
    ../../configs/k3s.nix
  ];

  services.k3s.role = "agent";
  services.k3s.token = "K1091d7c884febe5d8d64ce92e9687b7d971e9d5a744ffcd7fb816770b095c4cb5e::server:5fb8e655cb747a040b9e9d7b0f6e233333998b0682701e9ef9186e84b8d4e4e5";
}
