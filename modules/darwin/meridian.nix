{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.services.meridian;
  user = config.system.primaryUser;
  meridian = inputs.meridian.packages.${pkgs.stdenv.hostPlatform.system}.meridian;
  logPath = "${config.home-manager.users.${user}.home.homeDirectory}/Library/Logs/meridian.log";
in
{
  options.wthueb.services.meridian.enable = lib.mkEnableOption "Meridian";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user}.launchd.agents.meridian = {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe meridian) ];
        EnvironmentVariables.MERIDIAN_PASSTHROUGH = "1";
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
