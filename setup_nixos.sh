#!/bin/bash

# This script sets up a NixOS system using a flake-based configuration.

# Ensure that Nix is installed
if ! command -v nix --version > /dev/null 2>&1; then
  echo "Nix is not installed. Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Enable flakes in NixOS configuration
echo "Enabling flakes..."
sudo sed -i '/# nix.settings.experimental-features/a nix.settings.experimental-features = [ "nix-command" "flakes" ];' /etc/nixos/configuration.nix

# Rebuild NixOS configuration to apply flakes
echo "Rebuilding NixOS configuration..."
sudo nixos-rebuild switch

# Clone the repo
echo "Cloning the repository..."
git clone https://github.com/chowe99/nix-config.git ~/nix-config
cd ~/nix-config

# Run the NixOS rebuild using the flake
echo "Running flake-based NixOS rebuild..."
sudo nixos-rebuild switch --flake .#nixos

# Run Home Manager switch for user-specific configuration
echo "Running Home Manager switch..."
home-manager switch

echo "Setup completed."
