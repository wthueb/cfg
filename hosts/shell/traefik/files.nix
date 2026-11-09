{ ... }:
{
  routers = {
    files-public = {
      rule = "Host(`files.wi1.xyz`) && (Path(`/public`) || PathPrefix(`/public/`)) && !PathRegexp(`/$`)";
      priority = 100;
      service = "files-public";
    };
    files-private = {
      rule = "Host(`files.wi1.xyz`)";
      priority = 10;
      middlewares = [ "authelia" ];
      service = "files-private";
    };
  };

  services = {
    files-private.loadBalancer.servers = [ { url = "http://127.0.0.1:8090"; } ];
    files-public.loadBalancer.servers = [ { url = "http://127.0.0.1:8091"; } ];
  };
}
