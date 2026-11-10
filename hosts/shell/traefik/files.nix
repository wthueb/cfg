{ config, ... }:
let
  virtualHosts = config.services.nginx.virtualHosts;
  backendUrl =
    name:
    let
      listen = builtins.head virtualHosts.${name}.listen;
    in
    "http://${listen.addr}:${toString listen.port}";
in
{
  routers = {
    files-public = {
      rule = "Host(`${virtualHosts.files-public.serverName}`) && (Path(`/public`) || PathPrefix(`/public/`)) && !PathRegexp(`/$`)";
      priority = 100;
      service = "files-public";
    };
    files-private = {
      rule = "Host(`${virtualHosts.files-private.serverName}`)";
      priority = 10;
      middlewares = [ "authelia" ];
      service = "files-private";
    };
  };

  services = {
    files-private.loadBalancer.servers = [ { url = backendUrl "files-private"; } ];
    files-public.loadBalancer.servers = [ { url = backendUrl "files-public"; } ];
  };
}
