{ config, pkgs, username, ... }:

{
  systemd.services.stable-diffusion = {
    description = "Stable Diffusion WebUI (Automatic1111)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/home/${username}/stable-diffusion-webui";
      ExecStart = "${pkgs.nix}/bin/nix-shell --run './webui.sh --listen --api --medvram '";
      Restart = "always";
      RestartSec = 10;
      User = "${username}";  # Run as the specified user
      Group = "users";
    };
  };
}
