{
  self,
  pkgs,
  inputs,
  ...
}:
{
  fileSystems."/mnt/plex" = {
    # specify IP to avoid going through tailscale
    device = "192.168.1.207:/volume1/plex";
    fsType = "nfs";
  };

  networking.firewall.allowedTCPPorts = [ 32400 ];

  users.groups.plex.gid = 5000;

  users.users.wil = {
    extraGroups = [ "plex" ];
  };
}
