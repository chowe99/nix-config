{ inputs, config, pkgs, lib, ... }:
{
  services.caddy = {
    enable = true;

    virtualHosts."*.howse.top".extraConfig = ''
      tls /etc/ssl/certs/fullchain.pem /etc/ssl/certs/howse.top.key
      encode gzip
    '';

    virtualHosts."http://howse.top".extraConfig = ''
      redir https://howse.top{uri}
    '';

    virtualHosts."http://www.howse.top".extraConfig = ''
      redir https://howse.top{uri}
    '';

    virtualHosts."https://howse.top".extraConfig = ''
      encode gzip
      reverse_proxy 10.1.1.249:3000
    '';

    virtualHosts."https://www.howse.top".extraConfig = ''
      encode gzip
      reverse_proxy 10.1.1.249:3000
    '';

    virtualHosts."vaultwarden.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:8170
    '';

    virtualHosts."prowlarr.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:9696
    '';

    virtualHosts."git.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:1480
    '';

    virtualHosts."cloud.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:11000
      header {
        Host {host}
        X-Real-IP {remote}
        X-Forwarded-For {remote}
        X-Forwarded-Proto {scheme}
      }
      encode gzip
    '';

    virtualHosts."sab.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:5480
    '';

    virtualHosts."llm.howse.top".extraConfig = ''
      reverse_proxy http://10.1.1.249:8081
    '';

    virtualHosts."ollama.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.250:11434
    '';

    virtualHosts."searx.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:5347 {
        header_up X-Real-IP {remote_host}
      }
    '';

    virtualHosts."shop.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:3008
    '';

    # virtualHosts."http://ho.howse.top:80".extraConfig = ''
    #   reverse_proxy 10.1.1.249:4173
    # '';

    virtualHosts."comfy.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:8188
    '';

    virtualHosts."browser.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:7788
    '';

    virtualHosts."ttyd.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:7681
    '';

    virtualHosts."static.howse.top".extraConfig = ''
      root * /var/www/html/static
      file_server
      header {
        Content-Security-Policy "
          default-src 'self';
          script-src 'self' 'unsafe-inline' https://s3.tradingview.com https://*.tradingview.com;
          style-src 'self' 'unsafe-inline';
          img-src 'self' data: https://*.tradingview.com;
          frame-src 'self' https://www.tradingview.com https://*.tradingview.com;
          connect-src 'self' https://*.tradingview.com;
          frame-ancestors 'self' https://cloud.howse.top;
        "
      }
    '';

    virtualHosts."vnc.howse.top".extraConfig = ''
      root * /snap/novnc/current
      file_server {
        index vnc.html
      }
      handle /websockify {
        reverse_proxy 10.1.1.249:6081
      }
    '';

    virtualHosts."ntfy.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:8082
    '';

    virtualHosts."music.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:4533
    '';

    virtualHosts."lidarr.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:8686
    '';

    virtualHosts."deemix.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:6595
    '';

    virtualHosts."ytmd.howse.top".extraConfig = ''
      reverse_proxy 10.1.1.249:5121
    '';
    virtualHosts."dashboard.howse.top".extraConfig = ''
      reverse_proxy http://10.1.1.249:30000  # Use your NodePort
    '';
    virtualHosts."k3s.howse.top".extraConfig = ''
      reverse_proxy https://10.1.1.249:6443 {
        transport http {
          tls_insecure_skip_verify  # Skip verification for self-signed cert
        }
      }
    '';
  };
}
