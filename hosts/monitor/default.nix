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

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "ethtool"
      "softirqs"
      "systemd"
      "tcpstat"
    ];
  };

  services.prometheus.exporters.process = {
    enable = true;
    port = 9256;
    settings = {
      process_names = [
        {
          name = "{{.Comm}}";
          cmdline = [ ".+" ];
        }
      ];
    };
  };

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
      ];
    };
  };

  sops.secrets.influxdb-token = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.grafana.serviceConfig.User;
    restartUnits = [ "grafana.service" ];
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "25.05";
}
