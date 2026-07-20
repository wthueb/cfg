{ theme, ... }:
{
  routers.plex = {
    rule = "Host(`plex.wi1.xyz`) || Host(`willsplex.com`)";
    service = "plex";
    entryPoints = [
      "web"
      "websecure"
      "plex"
    ];
    middlewares = [ "plex-theme" ];
  };

  middlewares.plex-theme.plugin.themepark = {
    inherit theme;
    app = "plex";
  };

  services.plex.loadBalancer.servers = [ { url = "http://mbk:32400"; } ];
}
