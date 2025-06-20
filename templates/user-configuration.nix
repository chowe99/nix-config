# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, inputs, hostname, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
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
  boot.supportedFilesystems = [ "fuse" ];
  networking.hostName = hostname;
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
  services.getty.autologinUser = username;

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
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };



  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "plugdev" "input" "audio" "storage" "render" "libvirtd" "disk" "udisks2"];
    shell = pkgs.zsh;
  };

  age.secrets.gemini-api-key = {
    file = ../secrets/gemini-api-key.age; # Path relative to this configuration.nix
    path = "/run/agenix/gemini-api-key"; # Path to the decrypted file
    # The user 'nix' needs to read this for their .zshrc
    # Default owner is root, default mode is "0400"
    owner = username; # Set this to your username
    group = "users";
    mode = "0600"; # User read-only
  };

  age.secrets.openai-api-key = {
    file = ../secrets/openai-api-key.age; # Path relative to this configuration.nix
    path = "/run/agenix/openai-api-key"; # Path
    # The user 'nix' needs to read this for their .zshrc
    # Default owner is root, default mode is "0400"
    owner = username; # Set this to your username
    group = "users";
    mode = "0600"; # User read-only
  };

  age.secrets.anthropic-api-key = {
    file = ../secrets/anthropic-api-key.age; # Path relative to this configuration.nix
    path = "/run/agenix/anthropic-api-key"; # Path
    # The user 'nix' needs to read this for their .zshrc
    # Default owner is root, default mode is "0400"
    owner = username; # Set this to your username
    group = "users";
    mode = "0600"; # User read-only
  };

  age.secrets.k3s-token = {
    file = ./secrets/k3s-token.age;
    path = "/run/agenix/k3s-token";
    owner = username; # Or "k3s" if it needs to be owned by a k3s service user
      group = "users";
    mode = "600";
  };


  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    vim wget git
    waybar wofi swaylock swayidle
    hyprpolkitagent
    xdg-desktop-portal-hyprland kitty hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    killall
    gtk3 gtk4
    xdg-terminal-exec
    appimage-run
    virt-manager
    qemu_kvm
    libvirt
    spice-gtk # For SPICE display protocol
    swtpm # Software TPM for VMs
    mullvad-vpn # VPN client
    flatpak
  ];
  # enable mullvad
  services.mullvad-vpn.enable = true;

  services.flatpak.enable = true;

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
