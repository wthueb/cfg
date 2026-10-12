{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.gc;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  nixPackage =
    if config.nix.enable && config.nix.package != null then config.nix.package else pkgs.nix;
  pruneGenerations = pkgs.writeShellScript "home-manager-generation-pruning" (
    import ./prune-generations.nix {
      inherit lib;
      nixEnv =
        if isDarwin then "/nix/var/nix/profiles/default/bin/nix-env" else "${nixPackage}/bin/nix-env";
      olderThan = cfg.generations.olderThan;
      profiles = [
        "${config.xdg.stateHome}/nix/profiles/home-manager"
        "/nix/var/nix/profiles/per-user/${config.home.username}/home-manager"
        "${config.xdg.stateHome}/home-manager/profiles/home-manager"
      ];
    }
  );
  logPath = "${config.home.homeDirectory}/Library/Logs/nix-generation-pruning.log";
in
{
  config = lib.mkIf cfg.enable {
    nix.gc = lib.mkIf cfg.store.automatic {
      automatic = true;
      options = null;
      dates = if isDarwin then "daily" else "03:15";
      persistent = true;
    };

    launchd.agents = lib.mkIf isDarwin {
      nix-gc.config = lib.mkIf cfg.store.automatic {
        ProgramArguments = lib.mkForce [
          "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
        ];
        StartCalendarInterval = lib.mkForce [
          {
            Hour = 3;
            Minute = 15;
          }
        ];
      };

      nix-generation-pruning = lib.mkIf cfg.generations.enable {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            "/bin/wait4path /nix/store && exec ${pruneGenerations}"
          ];
          RunAtLoad = false;
          StartCalendarInterval = [
            {
              Hour = 3;
              Minute = 0;
            }
          ];
          StandardOutPath = logPath;
          StandardErrorPath = logPath;
        };
      };
    };

    systemd.user = lib.mkIf (!isDarwin && cfg.generations.enable) {
      services.nix-generation-pruning = {
        Unit = {
          Description = "Prune old Home Manager generations";
          Before = [ "nix-gc.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pruneGenerations}";
        };
      };

      timers.nix-generation-pruning = {
        Unit.Description = "Prune old Home Manager generations";
        Timer = {
          OnCalendar = "03:00";
          Persistent = true;
          Unit = "nix-generation-pruning.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
