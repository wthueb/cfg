{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/plex.nix
  ];

  wthueb.nas.shares.data.path = "/volume1/data";

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
    mailutils
  ];

  wthueb.video.enable = true;

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
  };

  users.users.wil.extraGroups = [ "docker" ];

  services.postfix = {
    enable = true;
    settings.main = {
      myhostname = config.networking.hostName;
    };
  };

  wthueb.exporters = {
    extraProcessNames = [
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
    ];
    cadvisor.enable = true;
  };

  services.alloy.enable = true;
  systemd.services.alloy.serviceConfig.User = "alloy";
  users.users.alloy = {
    isSystemUser = true;
    group = "alloy";
    extraGroups = [ "docker" ];
  };
  users.groups.alloy = { };

  environment.etc =
    lib.mapAttrs'
      (
        name: _:
        lib.nameValuePair "alloy/${name}" {
          source = ./alloy + "/${name}";
        }
      )
      (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".alloy" name) (
          builtins.readDir ./alloy
        )
      );

  systemd.services.alloy-qbittorrent-log-access = {
    wantedBy = [ "multi-user.target" ];
    before = [ "alloy.service" ];
    unitConfig.ConditionPathExists = "/opt/docker/plex/qbittorrent/qBittorrent/data/logs/qbittorrent.log";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.acl "setfacl"} -m u:alloy:r-- /opt/docker/plex/qbittorrent/qBittorrent/data/logs/qbittorrent.log";
    };
  };
  systemd.paths.alloy-qbittorrent-log-access = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/opt/docker/plex/qbittorrent/qBittorrent/data/logs";
  };

  services.ddclient = {
    enable = true;
    interval = "1min";
    configFile = config.sops.templates."ddclient.conf".path;
  };

  # ddclient's pre-start script resolves $USER when copying its config. Keep a
  # static account available in case the DynamicUser NSS entry is unavailable.
  users.users.ddclient = {
    isSystemUser = true;
    group = "ddclient";
  };
  users.groups.ddclient = { };

  sops.templates."ddclient.conf".content = ''
    cache=/var/lib/ddclient/ddclient.cache
    foreground=yes
    quiet=no
    verbose=yes

    ssl=yes

    use=web, web=https://api.ipify.org

    protocol=cloudflare
    ttl=1
    password=${config.sops.placeholder.cloudflare-token}
    zone=wi1.xyz
    wi1.xyz

    protocol=cloudflare
    ttl=1
    password=${config.sops.placeholder.cloudflare-token}
    zone=willsplex.com
    willsplex.com

    protocol=cloudflare
    ttl=1
    password=${config.sops.placeholder.cloudflare-token}
    zone=willsjellyfin.com
    willsjellyfin.com
  '';

  sops.secrets.cloudflare-token = { };

  system.stateVersion = "24.11";
}
