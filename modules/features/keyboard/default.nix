{ config, lib, ... }:
let
  cfg = config.wthueb.keyboard;
  skhd = config.home-manager.users.${config.system.primaryUser}.wthueb.services.skhd.package;
in
{
  imports = [
    ./kanata.nix
  ];

  config = lib.mkIf cfg.enable {
    wthueb.security.tcc.permissions = {
      accessibility = [ (lib.getExe skhd) ];
      inputMonitoring = [ (lib.getExe skhd) ];
    };

    assertions = [
      {
        assertion = config.wthueb.desktop.enable;
        message = "wthueb.keyboard requires wthueb.desktop.enable";
      }
    ];
  };
}
