{ inputs, config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    # host = "0.0.0.0";  # Listen on all interfaces
  };

  # Firewall rules for k3s
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      11434  # Ollama API server
    ];
  };
}
