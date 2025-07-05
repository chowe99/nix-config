{ inputs, config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    openFirewall = true;  # Automatically open firewall ports
    loadModels = [ "devstral:latest" ];  # Load the devstral model
    acceleration = "cuda";  # Use CUDA for acceleration if available
    host = "0.0.0.0";  # Listen on all interfaces
  };

  # Firewall rules for ollama
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [
  #     11434  # Ollama API server
  #   ];
  # };
}
