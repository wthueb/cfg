{ theme, ... }:
{
  routers.authelia = {
    rule = "Host(`auth.wi1.xyz`)";
    service = "authelia";
    middlewares = [ "authelia-theme" ];
  };

  middlewares = {
    authelia.forwardAuth = {
      address = "http://mbk:9091/api/authz/forward-auth";
      trustForwardHeader = true;
      authResponseHeaders = [
        "Remote-User"
        "Remote-Groups"
        "Remote-Email"
        "Remote-Name"
      ];
    };

    authelia-basic.forwardAuth = {
      address = "http://mbk:9091/api/verify?auth=basic";
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

  services.authelia.loadBalancer.servers = [ { url = "http://mbk:9091"; } ];
}
