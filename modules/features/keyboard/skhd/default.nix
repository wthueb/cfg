{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.keyboard;
  skhd = config.wthueb.services.skhd.package;
in
{
  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    wthueb.services.skhd = {
      enable = true;
      package = pkgs.skhd-zig;
      config = lib.replaceStrings [ "skhd -k" ] [ "${lib.getExe skhd} -k" ] (builtins.readFile ./skhdrc);
      extraPackages = [
        pkgs.yabai
        pkgs.sketchybar
        pkgs.jq
        config.programs.wezterm.package
      ];
    };

  };
}
