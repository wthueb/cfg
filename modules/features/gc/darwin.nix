{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.gc;
  pruneGenerations = pkgs.writeShellScript "nix-generation-pruning" (
    import ./prune-generations.nix {
      inherit lib;
      nixEnv = "/nix/var/nix/profiles/default/bin/nix-env";
      olderThan = cfg.generations.olderThan;
      profiles = [ "/nix/var/nix/profiles/system" ];
    }
  );
in
{
  options.assertions = lib.mkOption {
    apply =
      assertions:
      if cfg.enable && cfg.store.automatic then
        builtins.filter (a: a.assertion || a.message != "nix.gc.automatic requires nix.enable") assertions
      else
        assertions;
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.store.automatic {
        nix.package = pkgs.nix;
        nix.gc = {
          automatic = true;
          options = "";
          interval = {
            Hour = 3;
            Minute = 15;
          };
        };
      })
      {
        launchd.daemons.nix-generation-pruning = lib.mkIf cfg.generations.enable {
          command = "${pruneGenerations}";
          serviceConfig = {
            RunAtLoad = false;
            StartCalendarInterval = {
              Hour = 3;
              Minute = 0;
            };
            StandardOutPath = "/var/log/nix-generation-pruning.log";
            StandardErrorPath = "/var/log/nix-generation-pruning.log";
          };
        };
      }
    ]
  );
}
