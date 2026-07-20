{ theme, ... }:
{
  routers.tautulli = {
    rule = "Host(`wi1.xyz`) && PathPrefix(`/tautulli`)";
    service = "tautulli";
    middlewares = [ "tautulli-theme" ];
  };

  middlewares.tautulli-theme.plugin.themepark = {
    inherit theme;
    app = "tautulli";
  };

  services.tautulli.loadBalancer.servers = [ { url = "http://mbk:8181"; } ];
}
