{ config, ... }:
{
  services.prometheus = {
    enable = true;
    checkConfig = "syntax-only";
    globalConfig.scrape_interval = "10s";
    retentionTime = "90d";
  };

  sops.secrets.unpackerr-metrics-api-key = {
    sopsFile = ./secrets-prometheus.yaml;
    owner = config.systemd.services.prometheus.serviceConfig.User;
    restartUnits = [ "prometheus.service" ];
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "prometheus";
      host = "127.0.0.1";
      port = config.services.prometheus.port;
    }
  ];
}
