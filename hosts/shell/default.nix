{
  config,
  lib,
  ...
}:
{
  imports = [ ./hardware.nix ];

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
    32400
  ];

  services.traefik =
    let
      theme = "catppuccin-mocha";
    in
    {
      enable = true;
      environmentFiles = [ config.sops.templates."traefik.env".path ];

      staticConfigOptions = {
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
        };

        entryPoints = {
          web = {
            address = ":80";
            asDefault = true;
          };

          websecure = {
            address = ":443";
            asDefault = true;
            http.tls = {
              certResolver = "acmeResolver";
              domains = [
                {
                  main = "wi1.xyz";
                  sans = [ "*.wi1.xyz" ];
                }
                { main = "willsplex.com"; }
                { main = "willsjellyfin.com"; }
              ];
            };
          };

          plex = {
            address = ":32400";
            http.tls = { };
          };
        };

        log = {
          level = "DEBUG";
          format = "json";
        };

        accessLog = {
          format = "json";
          bufferingSize = 100;
        };

        api = {
          insecure = true;
          dashboard = true;
        };

        metrics.prometheus = {
          addEntryPointsLabels = true;
          addRoutersLabels = true;
          addServicesLabels = true;
        };

        ping.entryPoint = "traefik";

        certificatesResolvers.acmeResolver.acme = {
          email = "$ACME_EMAIL";
          storage = "${config.services.traefik.dataDir}/acme.json";
          dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = 0;
          };
        };

        experimental.plugins.themepark = {
          moduleName = "github.com/packruler/traefik-themepark";
          version = "v1.4.2";
        };
      };

      dynamicConfigOptions.http =
        let
          files = builtins.filter (path: lib.pathIsRegularFile path && lib.hasSuffix ".nix" (toString path)) (
            lib.filesystem.listFilesRecursive ./traefik
          );
        in
        lib.mkMerge (
          (map (f: (import f { inherit theme; })) files)
          ++ [
            {
              routers = {
                cfb-picks = {
                  rule = "Host(`cfb-picks.wi1.xyz`)";
                  service = "cfb-picks";
                };

                drake = {
                  rule = "Host(`drake.wi1.xyz`)";
                  service = "drake";
                  middlewares = [ "authelia" ];
                };

                homeassistant = {
                  rule = "Host(`home.wi1.xyz`)";
                  service = "homeassistant";
                };

                jdr = {
                  rule = "Host(`jdr.wi1.xyz`)";
                  service = "jdr";
                };

                grafana = {
                  rule = "Host(`grafana.wi1.xyz`)";
                  service = "grafana";
                };

                homarr = {
                  rule = "Host(`wi1.xyz`)";
                  service = "homarr";
                  priority = 1;
                };

                jellyfin = {
                  rule = "Host(`jellyfin.wi1.xyz`) || Host(`willsjellyfin.com`)";
                  service = "jellyfin";
                };
              };

              middlewares = {
                add-trailing-slash.redirectRegex = {
                  regex = "^(https?://[^/]+/[a-z0-9_]+)$";
                  replacement = "\${1}/";
                  permanent = true;
                };
              };

              services = {
                cfb-picks.loadBalancer.servers = [ { url = "http://mbk:8001"; } ];
                homarr.loadBalancer.servers = [ { url = "http://mbk:7575"; } ];
                jellyfin.loadBalancer.servers = [ { url = "http://mbk:8096"; } ];

                drake.loadBalancer.servers = [ { url = "http://drake"; } ];
                homeassistant.loadBalancer.servers = [ { url = "http://homeassistant:8123"; } ];
                jdr.loadBalancer.servers = [ { url = "http://jdr:5000"; } ];
                grafana.loadBalancer.servers = [ { url = "http://ida:3000"; } ];
              };
            }
          ]
        );
    };

  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".source = ./config.alloy;

  sops.secrets = {
    cloudflare-token = { };
    acme-email = { };
  };
  sops.templates."traefik.env" = {
    content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare-token}
      ACME_EMAIL=${config.sops.placeholder.acme-email}
    '';
    owner = config.systemd.services.traefik.serviceConfig.User;
    group = config.systemd.services.traefik.serviceConfig.Group;
    mode = "0400";
    restartUnits = [ "traefik.service" ];
  };

  system.stateVersion = "26.05";
}
