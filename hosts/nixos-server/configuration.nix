{ config, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.server = import ../../nixos/users/server/home.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
  };

  # Bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = false;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos-server";
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
  users.users.server = {
    isNormalUser = true;
    description = "server";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
  };

  # Auto-login
  services.getty.autologinUser = "server";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoLogin.relogin = true;
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "server";

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
    waybar wofi swaylock swayidle
    kitty superfile hyprshot
    iwgtk blueman pipewire wireplumber pavucontrol helvum
    brave lunarvim oh-my-posh wl-clipboard wl-clipboard-rs
    sddm-astronaut
    killall
    gtk3 gtk4
    wlr-randr
    yarn
    caddy
    # (rust-bin.stable.latest.default.override {
    #   extensions = [ "rust-src" ];
    # })
    gcc gnumake perl openssl zlib lua54Packages.lua pkg-config
    docker
  ];

  services.caddy.enable = true;
  services.caddy.configFile = "/etc/caddy/Caddyfile";

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono
    fira-code
  ];

  services.openssh.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ]; # Only open 80 and 443 for Caddy, plus 22 for SSH
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout = 180
    '';
  };

  # Docker
  virtualisation.docker.enable = true;

  # Create Docker networks
  systemd.services.create-docker-networks = {
    description = "Create Docker networks for containers";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    script = ''
      #!/bin/sh
      ${pkgs.docker}/bin/docker network create server_network || true
      ${pkgs.docker}/bin/docker network create media_network || true
    '';
  };

  # Define containers
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "3030:3030" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      volumes = [
        "/home/server/homepage:/app/config"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
    searxng = {
      image = "searxng/searxng:latest";
      ports = [ "5347:8080" ];
      environment = {
        PUBLIC = "true";
        instance_name = "SearX";
      };
      volumes = [
        "/home/server/searxng:/etc/searxng"
      ];
      extraOptions = [
        "--network=server_network"
      ];
      autoStart = true;
    };

    vaultwarden = {
      image = "vaultwarden/server:latest";
      ports = [ "8170:80" ];
      environment = {
        DOMAIN = "https://vaultwarden.howse.top";
        ADMIN_TOKEN = "redacted";
      };
      volumes = [
        "/home/server/vw-data:/data/"
      ];
      autoStart = true;
    };

    open-webui = {
      image = "ghcr.io/open-webui/open-webui:latest";
      ports = [ "8081:8080" ];
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      };
      volumes = [
        "open-webui:/app/backend/data"
      ];
      extraOptions = [
        "--network=server_network"
        "--add-host=host.docker.internal:172.22.0.1"
      ];
      autoStart = true;
    };

    lidarr = {
      image = "youegraillot/lidarr-on-steroids";
      ports = [ "8686:8686" "6595:6595" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/nas/lidarr/config:/config"
        "/mnt/nas/lidarr/config_deemix:/config_deemix"
        "/mnt/nas/music:/music"
        "/mnt/nas/complete:/downloads"
      ];
      extraOptions = [
        "--network=media_network"
      ];
      autoStart = true;
    };

    ytmd = {
      image = "yt-dlp-downloader";
      ports = [ "5121:5121" ];
      volumes = [
        "/mnt/nas/music:/music"
        "/home/server/ytm-downloader/test:/app/test"
      ];
      autoStart = true;
    };

    ntfy = {
      image = "binwiederhier/ntfy";
      ports = [ "8082:80" "8083:443" ];
      volumes = [
        "/var/cache/ntfy:/var/cache/ntfy"
        "/etc/ntfy:/etc/ntfy"
      ];
      cmd = [
        "serve"
        "--cache-file"
        "/var/cache/ntfy/cache.db"
        "--attachment-cache-dir"
        "/var/cache/ntfy/attachments"
      ];
      autoStart = true;
    };
  };

  # Ensure volume directories exist
  system.activationScripts = {
    createDockerVolumes = ''
      mkdir -p /home/server/searxng
      mkdir -p /home/server/vw-data
      mkdir -p /var/cache/ntfy
      mkdir -p /etc/ntfy
      mkdir -p /mnt/nas/lidarr/config
      mkdir -p /mnt/nas/lidarr/config_deemix
      mkdir -p /mnt/nas/music
      mkdir -p /mnt/nas/complete
      mkdir -p /home/server/ytm-downloader/test
      chown server:users /home/server/searxng
      chown server:users /home/server/vw-data
      chown server:users /home/server/ytm-downloader/test
    '';
  };

  # System state
  system.stateVersion = "24.11";
}
