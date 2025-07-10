{ config, pkgs, username, ... }:

{
  systemd.services.stable-diffusion = {
    description = "Stable Diffusion WebUI (Automatic1111)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/home/${username}/stable-diffusion-webui";
      # Use the virtual environment's bash and pass --skip-python-version-check
      ExecStart = "${pkgs.bash}/bin/bash /home/${username}/stable-diffusion-webui/webui.sh --listen --api --medvram --skip-python-version-check";
      Restart = "always";
      RestartSec = 10;
      # Set LD_LIBRARY_PATH for NixOS compatibility
      Environment = [
        "PATH=${pkgs.python310}/bin:${pkgs.git}/bin:$PATH"
        "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc pkgs.zlib ]}"
      ];
    };

    # Include dependencies in the service's PATH
    path = with pkgs; [
      python310
      git
      python310Packages.pip
      python310Packages.torch
      python310Packages.torchvision
      gcc
      gnumake
      which
    ];
  };
}
