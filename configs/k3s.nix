{ inputs, config, pkgs, ... }:
{
  services.k3s = {
    enable = true;
    # No need for extraFlags here; host-specific flags go in host configs
  };

  # Firewall rules for k3s
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443  # Kubernetes API server (control plane)
      2379  # etcd client
      2380  # etcd peer
      10250 # Kubelet
    ];
    allowedTCPPortRanges = [
      { from = 49152; to = 65535; }
    ];
    allowedUDPPorts = [
      8472  # Flannel VXLAN (default k3s networking)
    ];
  };

  # Useful tools
  environment.systemPackages = with pkgs; [
    kubectl  # CLI for managing the cluster
    k3s      # Ensure k3s CLI is available
    etcd
  ];
}
