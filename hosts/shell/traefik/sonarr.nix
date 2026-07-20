{ theme, ... }:
{
  routers = {
    sonarr = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sonarr`)";
      service = "sonarr";
      middlewares = [
        "authelia"
        "sonarr-theme"
      ];
    };

    sonarr-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sonarr/api`)";
      service = "sonarr";
    };

    sonarr4k = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sonarr4k`)";
      service = "sonarr4k";
      middlewares = [
        "authelia"
        "sonarr4k-theme"
      ];
    };

    sonarr4k-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sonarr4k/api`)";
      service = "sonarr4k";
    };
  };

  middlewares = {
    sonarr-theme.plugin.themepark = {
      inherit theme;
      app = "sonarr";
    };
    sonarr4k-theme.plugin.themepark = {
      inherit theme;
      app = "sonarr";
      addons = [
        "4k-logo"
        "4k-favicon"
      ];
    };
  };

  services = {
    sonarr.loadBalancer.servers = [ { url = "http://mbk:8989"; } ];
    sonarr4k.loadBalancer.servers = [ { url = "http://mbk:8990"; } ];
  };
}
