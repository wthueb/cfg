{ ... }:
{
  imports = [
    ../../modules/nixos/proxmox-guest.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      devices = [ "/dev/sda" ];
    };

    growPartition = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4257aff3-ee94-48b9-a8e1-57ba5bbb351e";
    fsType = "ext4";
    autoResize = true;
  };
}
