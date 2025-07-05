
{ inputs, config, pkgs, ... }:
{
  users.users.git = {
    isSystemUser = true;  # Marks git as a system user (no login shell by default)
      uid = 998;           # Specify the UID
      group = "git";       # Assign to a group named "git"
      description = "GitLab user";
  };

  users.groups.git = {
    gid = 998;  # Specify the GID to match UID
  };

  virtualisation.oci-containers.containers = {
    gitlab = {
      image = "gitlab/gitlab-ce:latest";
      hostname = "git.howse.top";
      ports = [
        "1480:80"
          "2222:22"
      ];
      volumes = [
        "/mnt/nas/gitlab/config:/etc/gitlab"
          "/mnt/nas/gitlab/logs:/var/log/gitlab"
          "/mnt/nas/gitlab/data:/var/opt/gitlab"
      ];
      extraOptions = [
        "--network=server_network"
      ];
      autoStart = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 1480 2222 ];
  };

};
