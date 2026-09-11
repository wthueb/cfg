{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.services.bartender;
  logPath = "${config.home.homeDirectory}/Library/Logs/bartender.log";
in
{
  options.wthueb.services.bartender = {
    enable = lib.mkEnableOption "Take control of your Menu bar";

    package = lib.mkPackageOption pkgs "bartender" { };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || pkgs.stdenv.isDarwin;
          message = "wthueb.services.bartender is only supported on macOS";
        }
      ];
    }
    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      home.packages = [ cfg.package ];

      launchd.agents.bartender = {
        enable = true;
        config =
          let
            major = lib.versions.major cfg.package.version;
          in
          {
            Program = "${cfg.package}/Applications/Bartender ${major}.app/Contents/MacOS/Bartender ${major}";
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = logPath;
            StandardErrorPath = logPath;
          };
      };
    })
  ];
}
