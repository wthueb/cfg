{
  self,
  pkgs,
  inputs,
  ...
}:
{
  fileSystems."/mnt/plex" = {
    device = "192.168.1.207:/volume1/plex";
    fsType = "nfs";
  };

  boot.supportedFilesystems = [ "nfs" ];
}
