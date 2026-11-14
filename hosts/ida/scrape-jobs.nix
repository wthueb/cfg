{
  self,
  config,
  lib,
  ...
}:
let
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
      job_name = "unpackerr";
      authorization = {
        type = "Bearer";
        credentials_file = config.sops.secrets.unpackerr-metrics-api-key.path;
      };
      static_configs = [ { targets = [ "mbk:5656" ]; } ];
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

  services.prometheus.scrapeConfigs = simpleJobs ++ specialJobs;
}
