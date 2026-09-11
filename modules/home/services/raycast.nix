{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.services.raycast;
  logPath = "${config.home.homeDirectory}/Library/Logs/raycast.log";
in
{
  options.wthueb.services.raycast = {
    enable = lib.mkEnableOption "Your shortcut to everything";

    package = lib.mkPackageOption pkgs "raycast" { };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || pkgs.stdenv.isDarwin;
          message = "wthueb.services.raycast is only supported on macOS";
        }
      ];
    }
    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      home.packages = [ cfg.package ];

      launchd.agents.raycast = {
        enable = true;
        config = {
          Program = "${cfg.package}/Applications/Raycast.app/Contents/MacOS/Raycast";
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = logPath;
          StandardErrorPath = logPath;
        };
      };
    })
  ];
}
