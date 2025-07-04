#!/bin/bash
sudo dnf install hyprland glib2-devel gtk3-devel sddm zsh flatpak
git clone https://github.com/JaKooLit/Fedora-Hyprland ~/
git clone https://github.com/chowe99/dotfiles ~/
sudo systemctl set-default graphical.target
sudo setenforce 0
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
#sudo mkdir -p /etc/nix
#sudo echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
#echo "/home/cod/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
nix run ~/nix-config#homeConfigurations.cod.activationPackage
home-manager switch --flake ~/nix-config#cod -b bak

