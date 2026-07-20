{ theme, ... }:
{
  routers = {
    sabnzbd = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sabnzbd`)";
      service = "sabnzbd";
      middlewares = [
        "authelia"
        "sabnzbd-theme"
      ];
    };

    sabnzbd-api = {
      rule = "Host(`wi1.xyz`) && PathPrefix(`/sabnzbd/api`)";
      service = "sabnzbd";
    };
  };

  middlewares.sabnzbd-theme.plugin.themepark = {
    inherit theme;
    app = "sabnzbd";
  };

  services.sabnzbd.loadBalancer.servers = [ { url = "http://mbk:9092"; } ];
}
