{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/nixos/proxmox-guest.nix
    inputs.i915-sriov.nixosModules.default
  ];

  wthueb.proxmoxGuest.swapSize = 32 * 1024; # 32GB

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [ "ip_tables" ];
  boot.extraModulePackages = [ pkgs.i915-sriov ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b6eacf5e-de09-44bb-a84c-522c3bde56ed";
    fsType = "ext4";
  };
}
