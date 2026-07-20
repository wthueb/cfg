{ theme, ... }:
{
  routers = {
    radarr = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/radarr`)";
      service = "radarr";
      middlewares = [
        "authelia"
        "radarr-theme"
      ];
    };

    radarr-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/radarr/api`)";
      service = "radarr";
    };

    radarr4k = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/radarr4k`)";
      service = "radarr4k";
      middlewares = [
        "authelia"
        "radarr4k-theme"
      ];
    };

    radarr4k-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/radarr4k/api`)";
      service = "radarr4k";
    };
  };

  middlewares = {
    radarr-theme.plugin.themepark = {
      inherit theme;
      app = "radarr";
    };
    radarr4k-theme.plugin.themepark = {
      inherit theme;
      app = "radarr";
      addons = [
        "4k-logo"
        "4k-favicon"
      ];
    };
  };

  services = {
    radarr.loadBalancer.servers = [ { url = "http://mbk:7878"; } ];
    radarr4k.loadBalancer.servers = [ { url = "http://mbk:7879"; } ];
  };
}
