
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 1480 2222 ];
  };

}
