{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.services.raycast;
in
{
  options.wthueb.services.raycast = {
    enable = lib.mkEnableOption "Your shortcut to everything";

    package = lib.mkPackageOption pkgs "raycast" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    launchd.user.agents.raycast = {
      serviceConfig = {
        Program = "${cfg.package}/Applications/Raycast.app/Contents/MacOS/Raycast";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
