{
  config,
  lib,
  pkgs,
  ...
}:
let
  traceEndpoint = "127.0.0.1:14317";
  prometheus = config.services.prometheus;
  removeNulls =
    value:
    if builtins.isAttrs value then
      lib.mapAttrs (_: removeNulls) (lib.filterAttrs (name: v: name != "_module" && v != null) value)
    else if builtins.isList value then
      map removeNulls value
    else
      value;
in
{
  services.prometheus.configText = builtins.toJSON (removeNulls {
    global = prometheus.globalConfig;
    scrape_configs = prometheus.scrapeConfigs;
    remote_write = prometheus.remoteWrite;
    remote_read = prometheus.remoteRead;
    rule_files = lib.optionals (!prometheus.enableAgentMode) (
      prometheus.ruleFiles
      ++ lib.optional (prometheus.rules != [ ]) (
        pkgs.writeText "prometheus.rules" (lib.concatStringsSep "\n" prometheus.rules)
      )
    );
    alerting.alertmanagers = prometheus.alertmanagers;
    tracing = {
      endpoint = traceEndpoint;
      client_type = "grpc";
      sampling_fraction = 1.0;
      insecure = true;
    };
  });

  services.grafana.settings = {
    "tracing.opentelemetry" = {
      custom_attributes = "service.name:grafana,host.name:${config.networking.hostName}";
      sampler_type = "probabilistic";
      sampler_param = 1.0;
    };
    "tracing.opentelemetry.otlp" = {
      address = traceEndpoint;
      propagation = "w3c";
      insecure = true;
    };
  };

  services.loki.configuration.tracing.enabled = true;

  systemd.services.loki.environment = {
    OTEL_TRACES_EXPORTER = "otlp";
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://${traceEndpoint}";
    OTEL_EXPORTER_OTLP_PROTOCOL = "grpc";
    OTEL_PROPAGATORS = "tracecontext,baggage";
    OTEL_TRACES_SAMPLER = "parentbased_traceidratio";
    OTEL_TRACES_SAMPLER_ARG = "1.0";
  };

  wthueb.services.alloy.extraConfig = ''
    otelcol.receiver.otlp "services" {
      grpc {
        endpoint = ${builtins.toJSON traceEndpoint}
      }
      output {
        traces = [otelcol.processor.memory_limiter.traces.input]
      }
    }

    otelcol.processor.memory_limiter "traces" {
      check_interval = "1s"
      limit = "256MiB"
      output {
        traces = [otelcol.processor.transform.traces.input]
      }
    }

    otelcol.processor.transform "traces" {
      trace_statements {
        context = "resource"
        statements = [
          `set(resource.attributes["host.name"], "${config.networking.hostName}")`,
          `set(resource.attributes["service.name"], "loki") where resource.attributes["service.name"] == "loki-all"`,
        ]
      }
      trace_statements {
        context = "span"
        statements = [
          `delete_key(span.attributes, "url.query")`,
          `replace_pattern(span.attributes["url.full"], "\\?.*$", "") where span.attributes["url.full"] != nil`,
          `replace_pattern(span.attributes["http.url"], "\\?.*$", "") where span.attributes["http.url"] != nil`,
          `replace_pattern(span.attributes["http.target"], "\\?.*$", "") where span.attributes["http.target"] != nil`,
        ]
      }
      output {
        traces = [otelcol.processor.batch.traces.input]
      }
    }

    otelcol.processor.batch "traces" {
      timeout = "5s"
      send_batch_size = 512
      send_batch_max_size = 1024
      output {
        traces = [otelcol.exporter.otlp.tempo.input]
      }
    }

    otelcol.exporter.otlp "tempo" {
      client {
        endpoint = "127.0.0.1:${lib.last (lib.splitString ":" config.services.tempo.settings.distributor.receivers.otlp.protocols.grpc.endpoint)}"
        tls {
          insecure = true
        }
      }
    }
  '';
}
