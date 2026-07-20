{ theme, ... }:
{
  routers = {
    prowlarr = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/prowlarr`)";
      service = "prowlarr";
      middlewares = [
        "authelia"
        "prowlarr-theme"
      ];
    };

    prowlarr-api = {
      rule = "Host(`wi1.xyz`) && PathRegexp(`^/prowlarr/[0-9]+`)";
      service = "prowlarr";
    };

    prowlarr-api-base = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/prowlarr/api`)";
      service = "prowlarr";
    };
  };

  middlewares.prowlarr-theme.plugin.themepark = {
    inherit theme;
    app = "prowlarr";
  };

  services.prowlarr.loadBalancer.servers = [ { url = "http://mbk:9696"; } ];
}
