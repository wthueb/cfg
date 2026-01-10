{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics.enable = false;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4257aff3-ee94-48b9-a8e1-57ba5bbb351e";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # 32GB
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
