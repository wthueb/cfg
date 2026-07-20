{ theme, ... }:
{
  routers = {
    bazarr = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/bazarr`)";
      service = "bazarr";
      middlewares = [
        "authelia"
        "bazarr-theme"
      ];
    };

    bazarr4k = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/bazarr4k`)";
      service = "bazarr4k";
      middlewares = [
        "authelia"
        "bazarr4k-theme"
      ];
    };
  };

  middlewares = {
    bazarr-theme.plugin.themepark = {
      inherit theme;
      app = "bazarr";
    };
    bazarr4k-theme.plugin.themepark = {
      inherit theme;
      app = "bazarr";
      addons = [ "4k-logo" ];
    };
  };

  services = {
    bazarr.loadBalancer.servers = [ { url = "http://mbk:6767"; } ];
    bazarr4k.loadBalancer.servers = [ { url = "http://mbk:6768"; } ];
  };
}
