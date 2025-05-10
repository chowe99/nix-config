# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

{
  imports =
    [
      # hardware scan
      ./hardware-configuration.nix
      # Home Manager as a NixOS module
      # "${hm}/nixos"

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
  services.system76 = {
    enable = true;
    power.enable = true;
  }
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true; # This might be automatically enabled by sddm

  # Enable the SDDM display manager.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.autoLogin.relogin = true;
  # services.xserver.displayManager.sddm.user = "nix";

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
  programs.hyprland.enable = true;
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    vim wget git
    hyprland waybar wofi swaylock swayidle
    xdg-desktop-portal-hyprland kitty dolphin hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    brave lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    sddm-astronaut
    killall
    gtk3 gtk4
  ];

  services.displayManager.sddm.theme = "sddm-astronaut";
  # services.displayManager.sddm.package = pkgs.sddm-astronaut;

  # programs.waybar.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono
    fira-code
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "24.11";
  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    # require password again after 1 minute
    Defaults        timestamp_timeout = 180

    # per-user override (only for user “nix”):
    # Defaults:nix   timestamp_timeout = 0
    '';
}
