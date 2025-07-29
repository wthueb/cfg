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
}
