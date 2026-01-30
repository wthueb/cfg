{ pkgs, ... }:
{
  programs.sketchybar = {
    enable = pkgs.stdenv.isDarwin;
    configType = "lua";
    luaPackage = pkgs.lua5_4;
    sbarLuaPackage = pkgs.sbarlua;
    config = {
      source = ./config;
      recursive = true;
    };
  };
}
