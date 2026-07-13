{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.services.bartender;
in
{
  options.wthueb.services.bartender = {
    enable = lib.mkEnableOption "Take control of your Menu bar";

    package = lib.mkPackageOption pkgs "bartender" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    launchd.user.agents.bartender = {
      serviceConfig =
        let
          major = lib.versions.major cfg.package.version;
        in
        {
          Program = "${cfg.package}/Applications/Bartender ${major}.app/Contents/MacOS/Bartender ${major}";
          RunAtLoad = true;
          KeepAlive = true;
        };
    };
  };
}
