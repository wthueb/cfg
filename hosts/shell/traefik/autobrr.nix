{ ... }:
{
  routers.autobrr = {
    rule = "Host(`wi1.xyz`) && PathPrefix(`/autobrr`)";
    service = "autobrr";
    middlewares = [ "add-trailing-slash" ];
  };

  services.autobrr.loadBalancer.servers = [ { url = "http://mbk:7474"; } ];
}
