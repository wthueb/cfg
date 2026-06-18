{
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nixos/proxmox-guest.nix
    inputs.disko.nixosModules.disko
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  disko.devices = {
    disk = {
      main = {
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
    };
  };
}
