# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nix = import ./../../nixos/users/nix/home.nix;
    backupFileExtension = "backup"; # Automatically back up conflicting files
    extraSpecialArgs = { inherit inputs; };
  };

  environment.variables = {
    WAYLAND_DISPLAY = "wayland-0";
    QT_QPA_PLATFORM = "wayland";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Latest kernel
  # boot.kernelPackages = pkgs.linuxPackages;
  boot.initrd.luks.devices."luks-1e8804fe-b173-49f8-a93e-2064fecdc501".device = "/dev/disk/by-uuid/1e8804fe-b173-49f8-a93e-2064fecdc501";
  networking.hostName = "nixos";
  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  powerManagement.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Perth";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };
  services.getty.autologinUser = "nix";

  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.autoLogin.relogin = true;
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.sddm.autoLogin.user = "nix";

  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "input" "render" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.hyprland.enable = true;
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    vim wget git
    waybar wofi swaylock swayidle
    xdg-desktop-portal-hyprland kitty dolphin hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    brave lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    sddm-astronaut
    killall
    gtk3 gtk4
  ];
  services.displayManager.sddm.theme = "sddm-astronaut";
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono
    fira-code
  ];
  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "24.11";
  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout = 180
  '';
  virtualisation.docker.enable = true;
}
