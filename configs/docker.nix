{ inputs, config, pkgs, lib, username, hostname, ... }:
{
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
      ports = [ "3000:3000" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        HOMEPAGE_ALLOWED_HOSTS = "howse.top";
      };
      volumes = [
        "/home/${username}/homepage:/app/config"
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
        "/home/${username}/searxng:/etc/searxng"
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
        "/home/${username}/vw-data:/data/"
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
        "/home/${username}/ytm-downloader/test:/app/test"
      ];
      autoStart = true;
    };

    nextcloud-aio-mastercontainer = {
      image = "nextcloud/all-in-one:latest";
      ports = [ "8080:8080" ];
      environment = {
        APACHE_PORT = "11000";
        APACHE_IP_BINDING = "127.0.0.1";
        NEXTCLOUD_MEMORY_LIMIT = "2048M";
      };
      volumes = [
        "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      extraOptions = [
        "--init"
        "--sig-proxy=false"
        "--name=nextcloud-aio-mastercontainer"
      ];
      autoStart = true;
    };
}
    # ntfy = {
    #   image = "binwiederhier/ntfy";
    #   ports = [ "8082:80" "8083:443" ];
    #   volumes = [
    #     "/var/cache/ntfy:/var/cache/ntfy"
    #     "/etc/ntfy:/etc/ntfy"
    #   ];
    #   cmd = [
    #     "serve"
    #     "--cache-file"
    #     "/var/cache/ntfy/cache.db"
    #     "--attachment-cache-dir"
    #     "/var/cache/ntfy/attachments"
    #   ];
    #   autoStart = true;
    # };
  };
}
