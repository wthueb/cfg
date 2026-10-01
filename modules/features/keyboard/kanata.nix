{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.keyboard;
in
{
  config = lib.mkIf cfg.enable {
    wthueb.services.kanata = {
      enable = true;
      package = pkgs.kanata.override { withCmd = false; };
      config = builtins.readFile ../../../dotfiles/.config/kanata/kanata.kbd;
    };

    wthueb.security.tcc.permissions =
      let
        kanata = lib.getExe config.wthueb.services.kanata.package;
      in
      {
        accessibility = [ kanata ];
        inputMonitoring = [ kanata ];
      };
  };
}
