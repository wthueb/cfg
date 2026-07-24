{
  config,
  lib,
  self,
  ...
}:
let
  hosts = builtins.filter (node: builtins.hasAttr "wthueb" node.config) (
    lib.mapAttrsToList (_: v: v) self.nixosConfigurations
  );

  # Targets auto-derived from every NixOS host in the flake. Each host declares
  # its exporters via wthueb.exporters; hosts with none contribute an empty list.
  autoEntries = builtins.concatMap (
    node:
    map (target: {
      inherit (target) job;
      target = "${node.config.networking.hostName}:${toString target.port}";
    }) node.config.wthueb.exporters.scrapeTargets
  ) hosts;

  # Static targets for hosts that are not NixOS systems in this flake,
  # merged into the matching auto-derived job.
  extraTargets = {
    node = [ "drake:9100" ];
  };

  jobNames = lib.unique ((map (e: e.job) autoEntries) ++ lib.attrNames extraTargets);

  simpleJobs = map (job: {
    job_name = job;
    static_configs = [
      {
        targets =
          (map (e: e.target) (lib.filter (e: e.job == job) autoEntries)) ++ (extraTargets.${job} or [ ]);
      }
    ];
  }) jobNames;

  # External hosts / jobs that need custom scrape options.
  specialJobs = [
    {
      job_name = "smart";
      scrape_interval = "60s";
      static_configs = [ { targets = [ "drake:9633" ]; } ];
    }
    {
      job_name = "gpu";
      static_configs = [ { targets = [ "drake:9835" ]; } ];
    }
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
          replacement = "localhost:9116";
        }
      ];
    }
    {
      job_name = "traefik";
      scrape_interval = "5s";
      static_configs = [ { targets = [ "mbk:8080" ]; } ];
    }
    {
      job_name = "qbittorrent";
      static_configs = [ { targets = [ "mbk:8090" ]; } ];
    }
  ];
in
{
  imports = [
    ./hardware.nix
  ];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "1y";
    scrapeConfigs = simpleJobs ++ specialJobs;
  };

  wthueb.exporters.enable = true;

  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = ./snmp-exporter-conf.yaml;
  };

  wthueb.services.mktxp = {
    enable = true;
    settings.listen = "127.0.0.1:49090";
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

  services.influxdb2.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
        domain = "grafana.wi1.xyz";
        root_url = "https://grafana.wi1.xyz";
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
