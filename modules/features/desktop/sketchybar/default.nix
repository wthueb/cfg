{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.sketchybar = {
      enable = pkgs.stdenv.isDarwin;
      configType = "lua";
      luaPackage = pkgs.lua5_5;
      sbarLuaPackage = pkgs.sbarlua;
      config = {
        source = ./config;
        recursive = true;
      };
    };
  };
}
