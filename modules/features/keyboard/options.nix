{ lib, ... }:
{
  options.wthueb.keyboard.enable = lib.mkEnableOption "Kanata keyboard remapping and skhd command hotkeys";
}
