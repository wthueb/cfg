{ ... }:
{
  routers.autopulse = {
    rule = "Host(`wi1.xyz`) && PathPrefix(`/autopulse`)";
    service = "autopulse";
    middlewares = [
      "authelia"
      "autopulse-redirect"
    ];
  };

  middlewares.autopulse-redirect.redirectRegex = {
    regex = "^(https?://[^/]+)/autopulse$";
    replacement = "\${1}/autopulse/ui";
    permanent = true;
  };

  services.autopulse.loadBalancer.servers = [ { url = "http://mbk:2875"; } ];
}
