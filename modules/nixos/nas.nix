{ config, lib, ... }:
let
  cfg = config.wthueb.nas;
in
{
  options.wthueb.nas = {
    host = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.207";
      description = ''
        Address of the NAS. An IP is used by default so traffic stays on the
        local network instead of going through Tailscale.
      '';
    };

    shares = lib.mkOption {
      description = "NFS shares to mount from the NAS, keyed by name.";
      default = { };
      example = {
        data.path = "/volume1/data";
      };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              path = lib.mkOption {
                type = lib.types.str;
                description = "Exported path of the share on the NAS.";
                example = "/volume1/data";
              };

              mountPoint = lib.mkOption {
                type = lib.types.str;
                default = "/mnt/${name}";
                description = "Local path to mount the share at.";
              };
            };
          }
        )
      );
    };
  };

  config.fileSystems = lib.mapAttrs' (
    _name: share:
    lib.nameValuePair share.mountPoint {
      device = "${cfg.host}:${share.path}";
      fsType = "nfs";
    }
  ) cfg.shares;
}
