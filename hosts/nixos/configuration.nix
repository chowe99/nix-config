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
  services.udisks2.enable = true;
  fileSystems."/run/media" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "nosuid" "nodev" "mode=755" "uid=1000" "gid=100" ];
  };
  security.polkit.enable = true;
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

  # hardware.system76.kernel-modules.enable = true;
  # hardware.system76.enableAll = true;
# Enable the X11 windowing system.
  # services.xserver.enable = true; # This might be automatically enabled by sddm

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # Enable the SDDM display manager.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoLogin.relogin = true;
  services.displayManager.defaultSession = "Hyprland";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nix";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };



  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "plugdev" "input" "audio" "storage" "render" "libvirtd" "disk" "udisks2"];
    shell = pkgs.zsh;
  };

  # age.secrets.gemini-api-key = {
  #   file = ../../secrets/gemini-api-key.age; # Path relative to this configuration.nix
  #   # The user 'nix' needs to read this for their .zshrc
  #   # Default owner is root, default mode is "0400"
  #   owner = "nix"; # Set this to your username
  #   mode = "0400"; # User read-only
  # };

  # age.secrets.openai-api-key = {
  #   file = ../../secrets/openai-api-key.age; # Path relative to this configuration.nix
  #   # The user 'nix' needs to read this for their .zshrc
  #   # Default owner is root, default mode is "0400"
  #   owner = "nix"; # Set this to your username
  #   mode = "0400"; # User read-only
  # };

  # age.secrets.anthropic-api-key = {
  #   file = ../../secrets/anthropic-api-key.age; # Path relative to this configuration.nix
  #   # The user 'nix' needs to read this for their .zshrc
  #   # Default owner is root, default mode is "0400"
  #   owner = "nix"; # Set this to your username
  #   mode = "0400"; # User read-only
  # };

  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    vim wget git
    waybar wofi swaylock swayidle
    hyprpolkitagent superfile
    xdg-desktop-portal-hyprland kitty hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    brave lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    sddm-astronaut
    killall
    gtk3 gtk4
    xdg-terminal-exec
    appimage-run
    virt-manager
    qemu_kvm
    libvirt
    spice-gtk # For SPICE display protocol
    swtpm # Software TPM for VMs
  ];

# Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false; # Run QEMU as user for security
      swtpm.enable = true; # Enable TPM emulation
    };
  };

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;



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
