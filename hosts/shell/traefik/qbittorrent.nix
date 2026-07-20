{ theme, ... }:
{
  routers = {
    qbittorrent = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/qbittorrent`)";
      service = "qbittorrent";
      middlewares = [
        "qbittorrent-strip"
        "add-trailing-slash"
        "qbittorrent-headers"
        "authelia"
        "qbittorrent-theme-headers"
        "qbittorrent-theme"
      ];
    };

    qbittorrent-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/qbittorrent/api/`)";
      service = "qbittorrent";
      middlewares = [
        "qbittorrent-strip"
        "add-trailing-slash"
        "qbittorrent-headers"
      ];
    };

    qui = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/qui`)";
      service = "qui";
      middlewares = [ "add-trailing-slash" ];
    };
  };

  middlewares = {
    qbittorrent-strip.stripPrefix.prefixes = [ "/qbittorrent/" ];

    qbittorrent-headers.headers.customRequestHeaders = {
      X-Frame-Options = "SAMEORIGIN";
      Referer = "";
      Origin = "";
    };

    qbittorrent-theme-headers.headers.customResponseHeaders = {
      x-webkit-csp = "";
      content-security-policy = "";
    };

    qbittorrent-theme.plugin.themepark = {
      inherit theme;
      app = "qbittorrent";
    };
  };

  services = {
    qbittorrent = {
      loadBalancer = {
        servers = [ { url = "http://mbk:7475"; } ];
        passHostHeader = false;
      };
    };
    qui.loadBalancer.servers = [ { url = "http://mbk:7476"; } ];
  };
}
