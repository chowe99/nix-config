# hosts/nixos/configuration.nix
{ config, pkgs, inputs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../templates/user-configuration.nix  # Include directly as a module
  ];
# Home Manager per-user activation
  home-manager.users.${username} = import ../../nixos/users/${username}/home.nix {
    inherit config pkgs lib inputs username hostname;
  };
}
