{ inputs, config, pkgs, ... }:
{
  # services.etcd = {
  #   enable = true;
  #   name = "whiteserver";
  #   initialCluster = "whiteserver=[invalid url, do not cite]
  #   advertiseClientUrls = [ [invalid url, do not cite] ];
  #   listenClientUrls = [ [invalid url, do not cite] ];
  #   listenPeerUrls = [ [invalid url, do not cite] ];
  #   initialAdvertisePeerUrls = [ "[invalid url, do not cite] ];
  #   openFirewall = true;
  # };

  services.k3s = {
    enable = true;
    extraFlags = "--cluster-init";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 6443 2379 2380 24007 24008 49152 49153 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  environment.systemPackages = with pkgs; [ kubectl glusterfs docker ];
}
