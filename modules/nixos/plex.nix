{ config, lib, ... }:
{
  options.wthueb.plex.enable = lib.mkEnableOption "Plex host integration";

  config = lib.mkIf config.wthueb.plex.enable {
    wthueb.nas.shares.plex.path = "/volume1/plex";

    networking.firewall.allowedTCPPorts = [ 32400 ];

    users.groups.plex.gid = 5000;

    users.users.wil.extraGroups = [ "plex" ];
  };
}
