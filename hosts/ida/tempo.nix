{ config, ... }:
{
  services.tempo = {
    enable = true;

    settings = {
      auth_enabled = false;
      usage_report.reporting_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3200;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9096;
      };
      distributor.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:4317";
      ingester = {
        max_block_duration = "5m";
        lifecycler.ring = {
          kvstore.store = "inmemory";
          replication_factor = 1;
        };
      };
      compactor.compaction.block_retention = "720h";
      metrics_generator = {
        ring = {
          kvstore.store = "inmemory";
          instance_addr = "127.0.0.1";
        };
        storage.path = "/var/lib/tempo/generator/wal";
        traces_storage.path = "/var/lib/tempo/generator/traces";
        processor.local_blocks = {
          filter_server_spans = false;
          flush_to_storage = true;
        };
      };
      overrides.defaults.metrics_generator.processors = [ "local-blocks" ];
      query_frontend.metrics = {
        max_duration = config.services.tempo.settings.compactor.compaction.block_retention;
        concurrent_jobs = 8;
      };
      storage.trace = {
        backend = "local";
        wal.path = "/var/lib/tempo/wal";
        local.path = "/var/lib/tempo/blocks";
      };
    };
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "tempo";
      host = "127.0.0.1";
      port = config.services.tempo.settings.server.http_listen_port;
    }
  ];
}
