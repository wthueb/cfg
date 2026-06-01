{ pkgs, ... }:
{
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
}
