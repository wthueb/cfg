{
  config,
  hostname,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "1y";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
              "drake:9100"
              "mbk:9100"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
            regex = "localhost(:.*)?";
            replacement = "monitor$1";
          }
        ];
      }
      {
        job_name = "process";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.process.port}"
              "mbk:9256"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
            regex = "localhost(:.*)?";
            replacement = "monitor$1";
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = [ "mbk:9080" ];
          }
        ];
      }
      {
        job_name = "smart";
        scrape_interval = "60s";
        static_configs = [
          {
            targets = [ "drake:9633" ];
          }
        ];
      }
      {
        job_name = "gpu";
        static_configs = [
          {
            targets = [ "drake:9835" ];
          }
        ];
      }
      {
        job_name = "snmp";
        static_configs = [
          {
            targets = [ "jdr" ];
          }
        ];
        metrics_path = "/snmp";
        params = {
          module = [ "synology" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9116";
          }
        ];
      }
    ];
  };

  wthueb.exporters.enable = true;

  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = ./snmp-exporter-conf.yaml;
  };

  services.influxdb2.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
        domain = hostname;
      };
      analytics.reporting_enabled = false;
      "auth.generic_oauth" = {
        enabled = true;
        allow_sign_up = false;
        auto_login = true;
        name = "Authelia";
        client_id = "grafana";
        client_secret = "\$__file{${config.sops.secrets.grafana-client-secret.path}}";
        scopes = "openid profile email groups";
        empty_scopes = false;
        auth_url = "https://auth.wi1.xyz/api/oidc/authorization";
        token_url = "https://auth.wi1.xyz/api/oidc/token";
        api_url = "https://auth.wi1.xyz/api/oidc/userinfo";
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
          url = "http://localhost:8086";
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
          type = "loki";
          url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
          jsonData = {
            maxLines = 5000;
          };
          isDefault = false;
          editable = false;
        }
      ];
    };
  };

  sops.secrets.grafana-client-secret = {
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  sops.secrets.grafana-secret-key = {
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };
      common = {
        ring = {
          instance_addr = "0.0.0.0";
          kvstore = {
            store = "inmemory";
          };
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };
      schema_config = {
        configs = [
          {
            from = "2026-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
      limits_config = {
        retention_period = "90d";
      };
      compactor = {
        working_directory = "/var/lib/loki/compactor";
        compaction_interval = "10m";
        retention_enabled = true;
        retention_delete_delay = "2h";
        retention_delete_worker_count = 150;
        delete_request_store = "filesystem";
      };
    };
  };

  sops.secrets.influxdb-token = {
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  system.stateVersion = "25.05";
}
