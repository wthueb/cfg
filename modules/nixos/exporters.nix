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
  };
}
