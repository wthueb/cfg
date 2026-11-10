{
  self,
  config,
  lib,
  ...
}:
let
  shell = self.nixosConfigurations.shell.config;
  autheliaUrl =
    (builtins.head shell.services.authelia.instances.main.settings.session.cookies).authelia_url;
in
{
  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
        domain = "grafana.wi1.xyz";
        root_url = "https://${config.services.grafana.settings.server.domain}";
      };
      analytics.reporting_enabled = false;
      metrics.enabled = true;
      "auth.generic_oauth" = {
        enabled = true;
        allow_sign_up = false;
        auto_login = true;
        name = "Authelia";
        client_id = "grafana";
        client_secret = "\$__file{${config.sops.secrets.grafana-client-secret.path}}";
        scopes = "openid profile email groups";
        empty_scopes = false;
        auth_url = "${autheliaUrl}/api/oidc/authorization";
        token_url = "${autheliaUrl}/api/oidc/token";
        api_url = "${autheliaUrl}/api/oidc/userinfo";
        use_pkce = true;
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        role_attribute_path = "contains(groups, 'Grafana Admins') && 'Admin' || contains(groups, 'Grafana Editors') && 'Editor' || 'Viewer'";
        name_attribute_path = "name";
        auth_style = "InHeader";
      };
      security.secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
        {
          name = "InfluxDB";
          type = "influxdb";
          access = "proxy";
          url = "http://localhost:${lib.last (lib.splitString ":" config.services.influxdb2.settings.http-bind-address)}";
          jsonData = {
            organization = "admin";
            version = "Flux";
          };
          secureJsonData = {
            token = "$__file{${config.sops.secrets.influxdb-token.path}}";
          };
          editable = false;
        }
        {
          name = "Loki";
          uid = "P8E80F9AEF21F6940";
          type = "loki";
          url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
          jsonData = {
            maxLines = 5000;
            derivedFields = [
              {
                name = "TraceID";
                matcherRegex = ''(?:TraceId|traceID|trace_id)"?\s*[:=]\s*"?([0-9a-fA-F]{32})'';
                datasourceUid = "tempo";
                url = "$\${__value.raw}";
                urlDisplayLabel = "View trace";
              }
            ];
          };
          isDefault = false;
          editable = false;
        }
        {
          name = "Tempo";
          uid = "tempo";
          type = "tempo";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.tempo.settings.server.http_listen_port}";
          jsonData = {
            nodeGraph.enabled = true;
            tracesToLogsV2 = {
              datasourceUid = "P8E80F9AEF21F6940";
              spanStartTimeShift = "-1m";
              spanEndTimeShift = "1m";
              tags = [
                {
                  key = "host.name";
                  value = "host_name";
                }
                {
                  key = "service.name";
                  value = "service_name";
                }
              ];
              filterByTraceID = true;
              filterBySpanID = false;
            };
          };
          isDefault = false;
          editable = false;
        }
      ];
    };
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "grafana";
      port = config.services.grafana.settings.server.http_port;
    }
  ];

  sops.secrets.grafana-client-secret = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  sops.secrets.grafana-secret-key = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  sops.secrets.influxdb-token = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };
}
