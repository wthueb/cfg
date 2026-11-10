{ config, ... }:
let
  nginx = config.services.nginx;
  common = {
    serverName = "files.wi1.xyz";
    root = "/srv/files";
    extraConfig = ''
      disable_symlinks on;
      absolute_redirect off;
    '';
    locations = {
      "= /public".return = "301 /public/";
      "~ (^|/)\\.".return = "404";
    };
  };
in
{
  systemd.tmpfiles.rules = [
    "d /srv/files 2750 wil ${nginx.group} -"
    "d /srv/files/public 2750 wil ${nginx.group} -"
    "a+ /srv/files - - - - default:user::rwx,default:group::r-x,default:mask::r-x,default:other::---"
    "a+ /srv/files/public - - - - default:user::rwx,default:group::r-x,default:mask::r-x,default:other::---"
  ];

  services.prometheus.exporters.nginx = {
    enable = true;
    scrapeUri = "http://127.0.0.1:8092/nginx_status";
  };

  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts = {
      localhost.listen = [
        {
          addr = "127.0.0.1";
          port = 8092;
        }
      ];

      files-private = common // {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8090;
          }
        ];

        locations = common.locations // {
          "/" = {
            tryFiles = "$uri $uri/ =404";
            extraConfig = "autoindex on;";
          };
        };

        extraConfig = common.extraConfig + ''
          add_header Cache-Control "private, no-store" always;
        '';
      };

      files-public = common // {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8091;
          }
        ];

        locations = common.locations // {
          "/".return = "404";
          "/public/" = {
            tryFiles = "$uri $uri/ =404";
            extraConfig = "autoindex off;";
          };
        };
      };
    };
  };
}
