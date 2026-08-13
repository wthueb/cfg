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

  # could use `mbk` here instead of raw IP but plex is broken with tailscale
  # https://forums.plex.tv/t/x-forwarded-for-and-x-real-ip-not-used-when-request-is-coming-from-tailscale-ip-100-x-x-x/898294
  services.plex.loadBalancer.servers = [ { url = "http://mbk.home.arpa:32400"; } ];
}
