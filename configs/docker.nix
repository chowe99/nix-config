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
}
