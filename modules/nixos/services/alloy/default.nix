{ config, lib, ... }:
let
  cfg = config.wthueb.services.alloy;
  sharedConfig = builtins.readFile ./config.alloy;
in
{
  options.wthueb.services.alloy = {
    enable = lib.mkEnableOption "Grafana Alloy log collection";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://ida:3100/loki/api/v1/push";
      description = "Loki HTTP push endpoint used by Alloy.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Alloy configuration appended after the shared journal collection and
        log normalization pipeline. Additional log sources should normally
        forward to `loki.process.strip_ansi.receiver`.
      '';
      example = lib.literalExpression ''
        builtins.readFile ./docker.alloy
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy.enable = true;

    environment.etc."alloy/config.alloy".text = ''
      ${sharedConfig}

      loki.write "default" {
        endpoint {
          url = ${builtins.toJSON cfg.lokiUrl}
        }
        external_labels = {
          host_name = constants.hostname,
        }
      }

      ${cfg.extraConfig}
    '';
  };
}
