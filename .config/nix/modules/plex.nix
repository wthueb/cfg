{
  self,
  pkgs,
  inputs,
  ...
}:
{
  fileSystems."/mnt/plex" = {
    # specify IP to avoid going through tailscale
    device = "192.168.1.207:/volume1/plex";
    fsType = "nfs";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "wilhueb@gmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "mbk" = {
        forceSSL = false;
        enableACME = false;
        locations = {
          "/" = {
            # organizr
            proxyPass = "http://127.0.0.1:7979/";
          };

          "/tautulli" = {
            proxyPass = "http://127.0.0.1:8181";
          };

          "/radarr" = {
            proxyPass = "http://127.0.0.1:7878";
            proxyWebsockets = true;
          };

          "/radarr4k" = {
            proxyPass = "http://127.0.0.1:7879";
            proxyWebsockets = true;
          };

          "/sonarr" = {
            proxyPass = "http://127.0.0.1:8989";
            proxyWebsockets = true;
          };

          "/sonarr4k" = {
            proxyPass = "http://127.0.0.1:8990";
            proxyWebsockets = true;
          };

          "/bazarr" = {
            proxyPass = "http://127.0.0.1:6767";
            proxyWebsockets = true;
          };

          "/bazarr4k" = {
            proxyPass = "http://127.0.0.1:6768";
            proxyWebsockets = true;
          };

          "/prowlarr" = {
            proxyPass = "http://127.0.0.1:9696";
            proxyWebsockets = true;
          };

          "/sabnzbd" = {
            proxyPass = "http://127.0.0.1:9092";
          };

          "/qbittorrent/" = {
            proxyPass = "http://127.0.0.1:8080/";
          };
        };
      };
    };
  };
}
