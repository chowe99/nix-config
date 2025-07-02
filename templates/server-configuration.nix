# templates/server-configuration.nix
# templates/server-configuration.nix
# Shared configuration template for all servers
{ config, pkgs, inputs, hostname, username, ... }:

let
  allServers = {
    whiteserver = "whiteserver";
    blackserver = "blackserver";
    asusserver = "asusserver";
  };
  thisServer = config.networking.hostName; # Must match "whiteserver", "blackserver", or "asusserver"
  peerServers = builtins.filter (s: s != thisServer) (builtins.attrNames allServers);
  peerIPs = builtins.map (s: allServers.${s}) peerServers;
  peerProbeScript = pkgs.writeShellScriptBin "glusterfs-peer-probe" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (builtins.map (peer: "${pkgs.glusterfs}/bin/gluster peer probe ${peer}") peerIPs)}
  '';
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
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "gluster" ];
    shell = pkgs.zsh;
  };


  age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key" # Use the system host private key
    ];

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
    file = ../secrets/k3s-token.age;
    path = "/run/agenix/k3s-token";
    owner = username; # Or "k3s" if it needs to be owned by a k3s service user
      group = "users";
    mode = "600";
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
    gcc gnumake perl openssl zlib lua54Packages.lua pkg-config

    # K3sS
    docker
    kubectl
    glusterfs

    # Network/Disk tools
    mdadm
    dig
    lsof
    nssTools
    caddy
    parted
    
    # hostname command
    coreutils
    inetutils
  ];

  # security.pki.certificateFiles = [
  #   "/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
  # ];
  # services.caddy.enable = true;
  # services.caddy.configFile = "/etc/caddy/Caddyfile";

  fonts.packages = with pkgs; [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];

  services.openssh.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 3000 3030 24007 24008 49152 49153 49154];
    allowedUDPPorts = [ 24007 24008 ];
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout = 180
    '';
  };

  # Enable GlusterFS on all servers
  services.glusterfs.enable = true;

  users.groups.gluster = {}; # Create gluster group

  systemd.services.glusterd-socket-permissions = {
    description = "Set permissions for GlusterFS socket";
    after = [ "glusterd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'while [ ! -S /var/run/glusterd.socket ]; do sleep 1; done; chown root:gluster /var/run/glusterd.socket; chmod 660 /var/run/glusterd.socket'";
      RemainAfterExit = true;
    };
  };

  systemd.tmpfiles.rules = [
      "d /var/log/glusterfs 0755 root root -"  # Ensure log directory exists
      "d /var/log/glusterfs 0775 root gluster -"
      "f /var/run/glusterd.socket 0660 root gluster -"  # Set socket permissions
  ];


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
  system.stateVersion = "25.05";
}
