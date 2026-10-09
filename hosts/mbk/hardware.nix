{ ... }:

{
  wthueb.proxmox-guest = {
    enable = true;
    i915-sriov = true;
    swapSize = 32 * 1024; # 32GB
  };

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };
  boot.kernelModules = [ "ip_tables" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b6eacf5e-de09-44bb-a84c-522c3bde56ed";
    fsType = "ext4";
  };
}
