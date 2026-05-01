{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/plex.nix
  ];

  fileSystems."/mnt/data" = {
    device = "192.168.1.207:/volume1/data";
    fsType = "nfs";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    config.services.cadvisor.port
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
    ffmpeg-full
    mailutils
  ];

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
  };

  users.users.wil.extraGroups = [ "docker" ];

  services.qemuGuest.enable = true;

  services.postfix = {
    enable = true;
    settings.main = {
      myhostname = "mbk";
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
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
    port = 9256;
    settings = {
      process_names = [
        {
          name = "sabnzbd";
          comm = [ "python3" ];
          cmdline = [ "SABnzbd.py" ];
        }
        {
          name = "bazarr";
          comm = [ "python3" ];
          cmdline = [ "bazarr" ];
        }
        {
          name = "{{.Comm}}";
          cmdline = [ ".+" ];
        }
        # {
        #   comm = [
        #     "Plex Media Serv"
        #     "Radarr"
        #     "Sonarr"
        #   ];
        # }
      ];
    };
  };

  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9080;
  };

  services.alloy.enable = true;
  systemd.services.alloy.serviceConfig.User = "alloy";
  users.users.alloy = {
    isSystemUser = true;
    group = "alloy";
    extraGroups = [ "docker" ];
  };
  users.groups.alloy = { };
  environment.etc."alloy/config.alloy".text = ''
    discovery.docker "containers" {
      host = "unix:///var/run/docker.sock"
    }

    discovery.relabel "logs_integrations_docker" {
      targets = discovery.docker.containers.targets

      rule {
        source_labels = ["__meta_docker_container_name"]
        regex         = "/(.*)"
        target_label  = "container_name"
      }

      rule {
        target_label = "instance"
        replacement  = constants.hostname
      }

      rule {
        target_label = "job"
        replacement  = "docker"
      }
    }

    loki.source.docker "containers" {
      host       = "unix:///var/run/docker.sock"
      targets    = discovery.relabel.logs_integrations_docker.output
      forward_to = [loki.write.loki.receiver]
    }

    loki.write "loki" {
      endpoint {
        url = "http://monitor:3100/loki/api/v1/push"
      }
    }
  '';

  system.stateVersion = "24.11";
}
