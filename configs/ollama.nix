{ inputs, config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    openFirewall = true;  # Automatically open firewall ports
    loadModels = [ 
      "devstral:latest" 
      "deepseek-r1:32b-qwen-distill-q4_K_M" 
      "gemma3:27b-it-q4_K_M"
      "gemma3:27b-it-qat"
    ];  # Load the devstral model
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
