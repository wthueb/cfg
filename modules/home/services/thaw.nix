{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.services.thaw;
  logPath = "${config.home.homeDirectory}/Library/Logs/thaw.log";
in
{
  options.wthueb.services.thaw = {
    enable = lib.mkEnableOption "Thaw menu bar manager";

    package = lib.mkPackageOption pkgs "thaw" { };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || pkgs.stdenv.isDarwin;
          message = "wthueb.services.thaw is only supported on macOS";
        }
      ];
    }
    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      home.packages = [ cfg.package ];

      launchd.agents.thaw = {
        enable = true;
        config = {
          Program = "${cfg.package}/Applications/Thaw.app/Contents/MacOS/Thaw";
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = logPath;
          StandardErrorPath = logPath;
        };
      };
    })
  ];
}
