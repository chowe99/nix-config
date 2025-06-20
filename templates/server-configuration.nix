# templates/server-configuration.nix
# templates/server-configuration.nix
# Shared configuration template for all servers
{ config, pkgs, inputs, hostname, username, ... }:

let
  k3sToken = "5fb8e655cb747a040b9e9d7b0f6e233333998b0682701e9ef9186e84b8d4e4e5"; # Generate with `openssl rand -hex 32`
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.logind = {
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    ARRAY /dev/md127 UUID=e22f6488:83684aca:f30ec314:f49242d1
  '';

  # Filesystem configuration for RAID
  fileSystems."/mnt/nas" = {
    device = "/dev/md127";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;

  # Time and locale
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

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
  };

  # Auto-login
  services.getty.autologinUser = username;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoLogin.relogin = true;
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  powerManagement.enable = true;
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim wget git
    wofi swaylock swayidle
    kitty superfile hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    killall
    gtk3 gtk4
    wlr-randr
    yarn
    # caddy
    gcc gnumake perl openssl zlib lua54Packages.lua pkg-config
    docker
    mdadm
    dig
    lsof
    nssTools
    caddy
  ];

  # security.pki.certificateFiles = [
  #   "/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
  # ];
  # services.caddy.enable = true;
  # services.caddy.configFile = "/etc/caddy/Caddyfile";

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono
    fira-code
  ];

  services.openssh.enable = true;
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 22 80 443 3000 3030];
  # };
  #
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout = 180
    '';
  };
  
  # Enable k3s (Server 1 as control plane)
  #services.k3s = {
    #enable = true;
    #role = "server";
    #token = k3sToken;
    #extraFlags = "--disable traefik"; # Disable default Traefik for custom ingress
  #};

  # Enable GlusterFS
  # services.glusterfs = {
  #   enable = true;
  #   servers = [ "100.64.65.24" "100.73.187.60" ]; # Whiteserver-ip blackserver-ip (tailscale)
  # };


  # Ensure volume directories exist
  system.activationScripts = {
    createDockerVolumes = ''
      mkdir -p /home/${username}/searxng
      mkdir -p /home/${username}/vw-data
      mkdir -p /var/cache/ntfy
      mkdir -p /etc/ntfy
      mkdir -p /mnt/nas/lidarr/config
      mkdir -p /mnt/nas/lidarr/config_deemix
      mkdir -p /mnt/nas/music
      mkdir -p /mnt/nas/complete
      mkdir -p /home/${username}/ytm-downloader/test
      chown ${username}:users /home/${username}/searxng
      chown ${username}:users /home/${username}/vw-data
      chown ${username}:users /home/${username}/ytm-downloader/test
    '';
  };

  # System state
  system.stateVersion = "24.11";
}
