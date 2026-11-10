{
  imports = [
    ./hardware.nix
    ./prometheus.nix
    ./scrape-jobs.nix
    ./exporters
    ./grafana
    ./loki.nix
    ./tempo.nix
    ./tracing.nix
    ./influxdb.nix
  ];

  system.stateVersion = "25.05";
}
