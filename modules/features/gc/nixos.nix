{ config, lib, ... }:
let
  cfg = config.wthueb.gc;
  pruneGenerations = import ./prune-generations.nix {
    inherit lib;
    nixEnv = "${config.nix.package}/bin/nix-env";
    olderThan = cfg.generations.olderThan;
    profiles = [ "/nix/var/nix/profiles/system" ];
  };
in
{
  config = lib.mkIf cfg.enable {
    nix.gc = lib.mkIf cfg.store.automatic {
      automatic = true;
      options = "";
      dates = "03:15";
      persistent = true;
    };

    systemd.services.nix-generation-pruning = lib.mkIf cfg.generations.enable {
      description = "Prune old NixOS generations";
      script = pruneGenerations;
      serviceConfig.Type = "oneshot";
      startAt = "03:00";
      restartIfChanged = false;
      before = [ "nix-gc.service" ];
    };

    systemd.timers.nix-generation-pruning = lib.mkIf cfg.generations.enable {
      timerConfig.Persistent = true;
    };
  };
}
