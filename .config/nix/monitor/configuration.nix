{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
  ];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    retentionTime = "1y";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
              "drake:9100"
              "mbk:9100"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
            regex = "localhost(:.*)?";
            replacement = "monitor$1";
          }
        ];
      }
      {
        job_name = "process";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.process.port}"
              "mbk:9256"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
            regex = "localhost(:.*)?";
            replacement = "monitor$1";
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = [ "mbk:9080" ];
          }
        ];
      }
      {
        job_name = "smart";
        scrape_interval = "60s";
        static_configs = [
          {
            targets = [ "drake:9633" ];
          }
        ];
      }
      {
        job_name = "gpu";
        static_configs = [
          {
            targets = [ "drake:9835" ];
          }
        ];
      }
      {
        job_name = "snmp";
        static_configs = [
          {
            targets = [ "jdr" ];
          }
        ];
        metrics_path = "/snmp";
        params = {
          module = [ "synology" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9116";
          }
        ];
      }
    ];
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
  };

  services.prometheus.exporters.process = {
    enable = true;
    port = 9256;
    settings = {
      process_names = [
        {
          name = "{{.Comm}}";
          cmdline = [ ".+" ];
        }
      ];
    };
  };

  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = ./snmp-exporter-conf.yml;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
      };
      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      extraCommands = ''
        iptables -A nixos-fw -p all -s 192.168.1.0/24 -j nixos-fw-accept
      '';
      extraStopCommands = ''
        iptables -D nixos-fw -p all -s 192.168.1.0/24 -j nixos-fw-accept || true
      '';
    };
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "ter-i20b";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    gcc
    git
    vim
    wget
  ];

  services.qemuGuest.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
    # only allow PasswordAuthentication on local network/tailscale
    extraConfig = ''
      PasswordAuthentication no

      Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10
        PasswordAuthentication yes
    '';
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.cron.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  systemd.watchdog.runtimeTime = "30s";

  users.users."wil" = {
    name = "wil";
    uid = 1000;
    home = "/home/wil";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
    ];
    shell = pkgs.nushell;
  };

  home-manager.users.wil = import ../home.nix { inherit pkgs; };

  services.getty.autologinUser = "wil";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system.stateVersion = "25.05";
}
