{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.services.codex-lb;
  user = config.system.primaryUser;
  homeDirectory = config.home-manager.users.${user}.home.homeDirectory;
  codex-lb = inputs.codex-lb.packages.${pkgs.stdenv.hostPlatform.system}.codex-lb;
  logPath = "${homeDirectory}/Library/Logs/codex-lb.log";
in
{
  options.wthueb.services.codex-lb.enable = lib.mkEnableOption "codex-lb";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user}.launchd.agents.codex-lb = {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe codex-lb) ];
        EnvironmentVariables = {
          CODEX_LB_DATA_DIR = "${homeDirectory}/.codex-lb";
          CODEX_LB_DASHBOARD_AUTH_MODE = "disabled";
        };
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        ProcessType = "Background";
        ThrottleInterval = 5;
        StandardOutPath = logPath;
        StandardErrorPath = logPath;
      };
    };
  };
}
