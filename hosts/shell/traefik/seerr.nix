{ theme, ... }:
{
  routers = {
    seerr = {
      rule = "Host(`overseerr.wi1.xyz`) || Host(`seerr.wi1.xyz`)";
      service = "seerr";
      middlewares = [ "seerr-theme" ];
    };

    seerr-jellyfin = {
      rule = "Host(`seerr-jellyfin.wi1.xyz`)";
      service = "seerr-jellyfin";
      middlewares = [ "seerr-theme" ];
    };
  };

  middlewares.seerr-theme.plugin.themepark = {
    inherit theme;
    app = "overseerr";
  };

  services = {
    seerr.loadBalancer.servers = [ { url = "http://mbk:5055"; } ];
    seerr-jellyfin.loadBalancer.servers = [ { url = "http://mbk:5056"; } ];
  };
}
