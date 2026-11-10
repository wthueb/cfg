{ config, ... }:
{
  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = ./snmp-exporter-conf.yaml;
  };

  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    configFile = ./blackbox-exporter.yaml;
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
    restartUnits = [ "mktxp.service" ];
  };
}
