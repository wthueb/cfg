{ config, ... }:
{
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "1y";
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "prometheus";
      host = "127.0.0.1";
      port = config.services.prometheus.port;
    }
  ];
}
