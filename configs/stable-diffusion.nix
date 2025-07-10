{ config, pkgs, username, ... }:

{
  systemd.services.stable-diffusion = {
    description = "Stable Diffusion WebUI (Automatic1111)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/home/${username}/stable-diffusion-webui";
      ExecStart = "${pkgs.nix}/bin/nix-shell /home/${username}/stable-diffusion-webui/shell.nix --command '/home/${username}/stable-diffusion-webui/webui.sh --listen --api'";
      Restart = "always";
      RestartSec = 10;
      User = "${username}";
      Group = "users";
      Environment = [
        "CUDA_PATH=${pkgs.cudatoolkit}"
        "CUDA_HOME=${pkgs.cudatoolkit}"
        "NIXPKGS_ALLOW_UNFREE=1"
        "NIX_PATH=nixpkgs=flake:nixpkgs:/nix/var/nix/profiles/per-user/root/channels"
      ];
    };
  };
}
