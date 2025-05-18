{
  self,
  pkgs,
  inputs,
  ...
}:
{
  fileSystems."/mnt/plex" = {
    device = "192.168.1.207:/volume1/plex";
    fsType = "nfs";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
          "/radarr4k" = {
            proxyPass = "http://127.0.0.1:7879";
            proxyWebsockets = true;
          };

          "/sonarr4k" = {
            proxyPass = "http://127.0.0.1:8990";
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

          "/qbittorrent/" = {
            proxyPass = "http://127.0.0.1:8080/";
          };

          "/sabnzbd" = {
            proxyPass = "http://127.0.0.1:9092";
          };
        };
      };
    };
  };
}
