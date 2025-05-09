# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
let
  # pull in the matching Home Manager NixOS module
  hm = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
    sha256 = "0gjfa3bv0m0kymxqla9iih11gjb6czyj942v34pyc7xy4qsx898k";
  };
in
{
  imports =
    [
      # hardware scan
      ./hardware-configuration.nix
      # Home Manager as a NixOS module
      "${hm}/nixos"
    ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.luks.devices."luks-d5702bf9-6eac-4449-bf8e-6a8fc777152f".device = "/dev/disk/by-uuid/d5702bf9-6eac-4449-bf8e-6a8fc777152f";
  networking.hostName = "nixos";
  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable     = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable  = true;
  };
  powerManagement.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Perth";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS         = "en_AU.UTF-8";
    LC_IDENTIFICATION  = "en_AU.UTF-8";
    LC_MEASUREMENT     = "en_AU.UTF-8";
    LC_MONETARY        = "en_AU.UTF-8";
    LC_NAME            = "en_AU.UTF-8";
    LC_NUMERIC         = "en_AU.UTF-8";
    LC_PAPER           = "en_AU.UTF-8";
    LC_TELEPHONE       = "en_AU.UTF-8";
    LC_TIME            = "en_AU.UTF-8";
  };
  services.displayManager.sddm.wayland.enable = true;
  # ————————————————————————————————————————————
  # Define the user 'nix' to match home-manager.users.nix
  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  # programs.hyprland.enable = true;
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    vim wget git
     waybar wofi swaylock swayidle
     kitty dolphin hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    brave lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
  ];
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "24.11";
}
