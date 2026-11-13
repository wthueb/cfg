{ inputs, lib, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  wthueb.proxmox-guest = {
    enable = true;
    i915-sriov = true;
    swapSize = 32 * 1024;
  };

  boot.kernelModules = [ "ip_tables" ];

  disko.devices.disk.main = {
    device = lib.mkDefault "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "500M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
