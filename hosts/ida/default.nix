{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  shell = self.nixosConfigurations.shell.config;
  autheliaUrl =
    (builtins.head shell.services.authelia.instances.main.settings.session.cookies).authelia_url;

  hosts = builtins.filter (node: builtins.hasAttr "wthueb" node.config) (
    lib.mapAttrsToList (_: v: v) self.nixosConfigurations
  );

  autoEntries = builtins.concatMap (
    node:
    map (
      target:
      target
      // {
        sourceHost = node.config.networking.hostName;
        target = "${
          if lib.hasInfix ":" target.host then "[${target.host}]" else target.host
        }:${toString target.port}";
      }
    ) node.config.wthueb.exporters.scrapeTargets
  ) hosts;

  extraEntries =
    map
      (target: {
        inherit target;
        job = "node";
        metricsPath = "/metrics";
        scrapeInterval = "10s";
      })
      [
        "ms01-a:9100"
        "ms01-b:9100"
      ];

  jobs = lib.groupBy (entry: entry.job) (autoEntries ++ extraEntries);

  simpleJobs = lib.mapAttrsToList (job: entries: {
    job_name = job;
    metrics_path = (builtins.head entries).metricsPath;
    scrape_interval = (builtins.head entries).scrapeInterval;
    static_configs = [ { targets = map (entry: entry.target) entries; } ];
  }) jobs;

  # External hosts / jobs that need custom scrape options.
  specialJobs = [
    {
      job_name = "mktxp";
      static_configs = [ { targets = [ config.wthueb.services.mktxp.settings.listen ]; } ];
    }
    {
      job_name = "snmp-jdr";
      static_configs = [ { targets = [ "jdr" ]; } ];
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
          replacement = "localhost:${toString config.services.prometheus.exporters.snmp.port}";
        }
      ];
    }
    {
      job_name = "qbittorrent";
      static_configs = [ { targets = [ "mbk:8090" ]; } ];
    }
    {
      job_name = "wi1-bot";
      static_configs = [ { targets = [ "mbk:9000" ]; } ];
    }
    {
      job_name = "proxmox-api";
      metrics_path = "/probe";
      params.module = [ "proxmox_https" ];
      static_configs = [
        {
          targets = [ "https://ms01-a:8006/api2/json/version" ];
          labels.node = "ms01-a";
        }
        {
          targets = [ "https://ms01-b:8006/api2/json/version" ];
          labels.node = "ms01-b";
        }
      ];
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
          replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
        }
      ];
    }
  ];
in
{
  imports = [
    ./hardware.nix
  ];

  assertions =
    lib.mapAttrsToList (job: entries: {
      assertion = builtins.all (
        entry:
        entry.metricsPath == (builtins.head entries).metricsPath
        && entry.scrapeInterval == (builtins.head entries).scrapeInterval
      ) entries;
      message = "Prometheus targets for job ${job} must use the same metrics path and scrape interval.";
    }) jobs
    ++ map (entry: {
      assertion =
        builtins.elem entry.host [
          "127.0.0.1"
          "::1"
          "localhost"
        ]
        -> entry.sourceHost == config.networking.hostName;
      message = "Prometheus cannot scrape loopback target ${entry.job} on remote host ${entry.sourceHost}.";
    }) autoEntries;

  wthueb.exporters.scrapeTargets = [
    {
      job = "prometheus";
      host = "127.0.0.1";
      port = config.services.prometheus.port;
    }
    {
      job = "grafana";
      port = config.services.grafana.settings.server.http_port;
    }
    {
      job = "loki";
      port = config.services.loki.configuration.server.http_listen_port;
    }
    {
      job = "influxdb";
      port = lib.toInt (
        lib.last (lib.splitString ":" config.services.influxdb2.settings.http-bind-address)
      );
    }
  ];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "1y";
    scrapeConfigs = simpleJobs ++ specialJobs;
  };

  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = ./snmp-exporter-conf.yaml;
  };

  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    configFile = pkgs.writeText "blackbox-exporter.yaml" ''
      modules:
        proxmox_https:
          prober: http
          timeout: 5s
          http:
            method: GET
            valid_status_codes:
              - 200
              - 401
            preferred_ip_protocol: ip4
            follow_redirects: false
            tls_config:
              insecure_skip_verify: true
    '';
  };

  wthueb.services.mktxp = {
    enable = true;
    settings = {
      listen = "127.0.0.1:49090";
      bandwidth = false;
      bandwidth_test_interval = 900;
    };
    defaults.credentials_file = config.sops.secrets.mktxp.path;
    routers.mt-pipeline = {
      hostname = "192.168.1.232";
      connection_stats = true;
      poe = false;
    };
  };

  sops.secrets.mktxp = {
    sopsFile = ./secrets-mktxp.yaml;
    format = "yaml";
    key = "";

    # Read as root by systemd LoadCredential, then handed to the mktxp DynamicUser.
    restartUnits = [ "mktxp.service" ];
  };

  services.influxdb2 = {
    enable = true;
    settings = {
      http-bind-address = ":8086";
      metrics-disabled = false;
    };
  };

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
      pattern_ingester = {
        enabled = true;
      };
    };
  };

  sops.secrets.influxdb-token = {
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  system.stateVersion = "25.05";
}
