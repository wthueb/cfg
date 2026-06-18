{ config, lib, ... }:
let
  cfg = config.wthueb.exporters;
in
{
  options.wthueb.exporters = {
    enable = lib.mkEnableOption "Prometheus node and process exporters";

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
              description = "Port the exporter listens on.";
            };
          };
        }
      );
      internal = true;
      default = [ ];
      description = ''
        Exporters this host exposes. Consumed by the monitor host to build its
        Prometheus scrapeConfigs. Computed from the enabled exporters above.
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

    networking.firewall.allowedTCPPorts = lib.optional cfg.cadvisor.enable cfg.cadvisor.port;

    wthueb.exporters.scrapeTargets = [
      {
        job = "node";
        port = cfg.ports.node;
      }
      {
        job = "process";
        port = cfg.ports.process;
      }
    ]
    ++ lib.optional cfg.cadvisor.enable {
      job = "cadvisor";
      port = cfg.cadvisor.port;
    };
  };
}
