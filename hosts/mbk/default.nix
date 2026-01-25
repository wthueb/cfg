{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/plex.nix
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

  users.users."wil".extraGroups = [ "docker" ];

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

  system.stateVersion = "24.11";
}
