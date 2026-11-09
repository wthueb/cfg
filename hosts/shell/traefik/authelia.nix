{
  config,
  lib,
  theme,
  ...
}:
let
  address = config.services.authelia.instances.main.settings.server.address;
  url = "http://${lib.removeSuffix "/" (lib.removePrefix "tcp://" address)}";
in
{
  routers.authelia = {
    rule = "Host(`auth.wi1.xyz`)";
    service = "authelia";
    middlewares = [ "authelia-theme" ];
  };

  middlewares = {
    authelia.forwardAuth = {
      address = "${url}/api/authz/forward-auth";
      trustForwardHeader = true;
      authResponseHeaders = [
        "Remote-User"
        "Remote-Groups"
        "Remote-Email"
        "Remote-Name"
      ];
    };

    authelia-theme.plugin.themepark = {
      inherit theme;
      app = "authelia";
    };
  };

  services.authelia.loadBalancer.servers = [ { inherit url; } ];
}
