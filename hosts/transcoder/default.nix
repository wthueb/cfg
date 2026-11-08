{ config, pkgs, ... }:
let
  workerConfig = (pkgs.formats.yaml { }).generate "wi1-bot-transcoder.yaml" {
    general.log_format = "logfmt";
    worker = {
      webhook_url = "http://mbk:9000";
      worker_name = config.networking.hostName;
      poll_interval = 3;
      tmp_dir = "/work";
    };
    transcoding.profiles.good = {
      hwaccel = "qsv";
      video_params = "-c hevc_qsv -b 2000k";
      audio_params = "-c aac -ac 2 -b 128k";
      languages = "eng";
      keep_original_language = true;
      fallback = {
        video_params = "-c libx265 -preset medium -b 2000k -maxrate 4000k -bufsize 4000k";
        audio_params = "-c aac -ac 2 -b 128k";
      };
    };
  };
in
{
  imports = [ ./hardware.nix ];

  wthueb.nas.shares.plex.path = "/volume1/plex";

  users.groups.plex.gid = 5000;
  users.users.wil.extraGroups = [ "plex" ];

  virtualisation = {
    podman = {
      enable = true;
      autoPrune.enable = true;
    };
    oci-containers.containers = {
      wi1-bot-transcoder = {
        image = "ghcr.io/wthueb/wi1-bot-transcoder:master";
        autoStart = true;
        labels."io.containers.autoupdate" = "registry";
        user = "1000:5000";
        environment = {
          WB_CONFIG_PATH = "/config/config.yaml";
          WB_LOG_DIR = "/logs";
        };
        volumes = [
          "${workerConfig}:/config/config.yaml:ro"
          "${config.wthueb.nas.shares.plex.mountPoint}:/data"
          "/var/lib/wi1-bot-transcoder:/work"
          "/var/log/wi1-bot-transcoder:/logs"
        ];
        extraOptions = [
          "--device=/dev/dri"
          "--group-add=${toString config.users.groups.render.gid}"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
        ];
      };
    };
  };

  systemd = {
    timers.podman-auto-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = [
          ""
          "*-*-* *:00/15:00"
        ];
        RandomizedDelaySec = 0;
        AccuracySec = "1s";
      };
    };
    tmpfiles.rules = [
      "d /var/lib/wi1-bot-transcoder 0750 wil plex -"
      "d /var/log/wi1-bot-transcoder 0750 wil plex -"
    ];
    services.podman-wi1-bot-transcoder = {
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [ config.wthueb.nas.shares.plex.mountPoint ];
      serviceConfig.RestartSec = "10s";
    };
  };

  wthueb.exporters.cadvisor.enable = true;

  system.stateVersion = "26.05";
}
