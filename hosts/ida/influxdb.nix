{
  config,
  lib,
  ...
}:
{
  services.influxdb2 = {
    enable = true;
    settings = {
      http-bind-address = ":8086";
      metrics-disabled = false;
    };
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "influxdb";
      port = lib.toInt (
        lib.last (lib.splitString ":" config.services.influxdb2.settings.http-bind-address)
      );
    }
  ];
}
