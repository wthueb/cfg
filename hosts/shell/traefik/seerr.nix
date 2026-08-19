{ theme, ... }:
{
  routers = {
    seerr = {
      rule = "Host(`seerr.willsplex.com`)";
      service = "seerr";
      middlewares = [ "seerr-theme" ];
    };
    seerr-old = {
      rule = "Host(`overseerr.wi1.xyz`) || Host(`seerr.wi1.xyz`)";
      service = "noop@internal";
      middlewares = [ "redirect-to-seerr-plex" ];
    };

    seerr-jellyfin = {
      rule = "Host(`seerr.willsjellyfin.com`)";
      service = "seerr-jellyfin";
      middlewares = [ "seerr-theme" ];
    };
  };

  middlewares = {
    seerr-theme.plugin.themepark = {
      inherit theme;
      app = "overseerr";
    };

    redirect-to-seerr-plex.redirectRegex = {
      regex = "^https?://[^/]+\\.wi1\\.xyz(/.*)";
      replacement = "https://seerr.willsplex.com\${1}";
      permanent = true;
    };
  };

  services = {
    seerr.loadBalancer.servers = [ { url = "http://mbk:5055"; } ];
    seerr-jellyfin.loadBalancer.servers = [ { url = "http://mbk:5056"; } ];
  };
}
