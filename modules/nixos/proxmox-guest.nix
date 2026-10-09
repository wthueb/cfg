{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
let
  cfg = config.wthueb.proxmox-guest;
in
{
  imports = [ inputs.i915-sriov.nixosModules.default ];

  options.wthueb.proxmox-guest = {
    enable = lib.mkEnableOption "Proxmox guest integration";
    i915-sriov = lib.mkEnableOption "Intel i915 SR-IOV graphics support";

    swapSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8 * 1024;
      description = "Size of /swapfile in MiB.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import (modulesPath + "/profiles/qemu-guest.nix") { })
      {
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
      }
      (lib.mkIf cfg.i915-sriov {
        boot.extraModulePackages = [ pkgs.i915-sriov ];

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime
            vpl-gpu-rt
          ];
        };
      })
    ]
  );
}
