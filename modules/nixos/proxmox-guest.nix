{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.wthueb.proxmoxGuest;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options.wthueb.proxmoxGuest = {
    swapSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8 * 1024;
      description = "Size of /swapfile in MiB.";
    };
  };

  # No enable flag: importing this module is the opt-in. Guest hosts import it
  # from their hardware.nix and override swapSize as needed.
  config = {
    services.qemuGuest.enable = true;

    boot.initrd.availableKernelModules = [
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];

    hardware.cpu.intel.updateMicrocode = true;

    swapDevices = [
      {
        device = "/swapfile";
        size = cfg.swapSize;
      }
    ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
