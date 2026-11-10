{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.wthueb.exporters;
  exporterOptions = options.services.prometheus.exporters.type.getSubOptions [ ];
  exporterNames = lib.attrNames (
    lib.filterAttrs (
      _: option: (option.visible or true) != false && (option.type.name or null) == "submodule"
    ) exporterOptions
  );
  enabledExporters = lib.filterAttrs (_: exporter: exporter.enable) (
    lib.genAttrs exporterNames (name: config.services.prometheus.exporters.${name})
  );
  textfileDirectory = "/var/lib/prometheus-node-exporter";
in
{
  options.wthueb.exporters = {
    enable = lib.mkEnableOption "Prometheus service metrics and host exporters";

    ports = {
      node = lib.mkOption {
        type = lib.types.port;
        default = 9100;
        description = "Port for the node exporter.";
      };

      process = lib.mkOption {
        type = lib.types.port;
        default = 9256;
        description = "Port for the process exporter.";
      };
    };

    extraProcessNames = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = ''
        Extra process_names matchers for the process exporter, prepended to the
        catch-all that groups any remaining processes by command name.
      '';
      example = lib.literalExpression ''
        [
          {
            name = "sabnzbd";
            comm = [ "python3" ];
            cmdline = [ "SABnzbd.py" ];
          }
        ]
      '';
    };

    cadvisor = {
      enable = lib.mkEnableOption "cAdvisor container metrics exporter";

      port = lib.mkOption {
        type = lib.types.port;
        default = 9080;
        description = "Port for the cAdvisor exporter.";
      };
    };

    scrapeTargets = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            job = lib.mkOption {
              type = lib.types.str;
              description = "Prometheus job name this exporter belongs to.";
            };

            port = lib.mkOption {
              type = lib.types.port;
              description = "Port the metrics endpoint listens on.";
            };

            host = lib.mkOption {
              type = lib.types.str;
              default = config.networking.hostName;
              description = "Address reachable by ida; loopback is only valid for ida itself.";
            };

            metricsPath = lib.mkOption {
              type = lib.types.str;
              default = "/metrics";
              description = "HTTP path of the Prometheus metrics endpoint.";
            };

            scrapeInterval = lib.mkOption {
              type = lib.types.str;
              default = "10s";
              description = "Scrape interval, which must agree across targets in a job.";
            };
          };
        }
      );
      internal = true;
      default = [ ];
      description = ''
        Metrics endpoints this host exposes. Consumed by ida to build its
        Prometheus scrapeConfigs. Enabled NixOS Prometheus exporters are
        registered automatically; native service endpoints can be appended.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = cfg.ports.node;
      enabledCollectors = [
        "ethtool"
        "softirqs"
        "systemd"
        "tcpstat"
      ];
      extraFlags = [
        "--collector.ethtool.device-exclude=^veth.*$"
        "--collector.netdev.device-exclude=^veth.*$"
        "--collector.textfile.directory=${textfileDirectory}"
        "--collector.systemd.enable-restarts-metrics"
        "--collector.systemd.enable-start-time-metrics"
      ];
    };

    services.prometheus.exporters.process = {
      enable = true;
      port = cfg.ports.process;
      settings.process_names = cfg.extraProcessNames ++ [
        {
          name = "{{.Comm}}";
          cmdline = [ ".+" ];
        }
      ];
    };

    services.cadvisor = lib.mkIf cfg.cadvisor.enable {
      enable = true;
      listenAddress = "0.0.0.0";
      port = cfg.cadvisor.port;
    };

    systemd.services.cadvisor = lib.mkIf (cfg.cadvisor.enable && config.virtualisation.podman.enable) {
      requires = [ "podman.socket" ];
      after = [ "podman.socket" ];
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.cadvisor.enable cfg.cadvisor.port;

    services.prometheus.exporters.postfix.enable = lib.mkDefault config.services.postfix.enable;

    systemd.tmpfiles.rules = [ "d ${textfileDirectory} 0755 root root -" ];

    systemd.services.tailscale-metrics = lib.mkIf config.services.tailscale.enable {
      description = "Write Tailscale client metrics for node-exporter";
      after = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe config.services.tailscale.package} metrics write ${textfileDirectory}/tailscale.prom";
        TimeoutStartSec = "10s";
        UMask = "0022";
      };
    };

    systemd.timers.tailscale-metrics = lib.mkIf config.services.tailscale.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "30s";
        AccuracySec = "1s";
      };
    };

    wthueb.exporters.scrapeTargets =
      lib.mapAttrsToList (name: exporter: {
        job = name;
        inherit (exporter) port;
        host =
          if
            builtins.elem exporter.listenAddress [
              "0.0.0.0"
              "::"
              "[::]"
              ""
            ]
          then
            config.networking.hostName
          else
            exporter.listenAddress;
        metricsPath = exporter.telemetryPath or "/metrics";
      }) enabledExporters
      ++ lib.optional cfg.cadvisor.enable {
        job = "cadvisor";
        port = cfg.cadvisor.port;
      };
  };
}
