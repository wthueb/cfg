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
  imports = [ ./sketchybar ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      brave
      firefox-bin
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
      nil
      nixfmt
      plezy
      postman
      spotify
      thunderbird-esr-bin
      vesktop
      winbox
    ];

    fonts.fontconfig.enable = true;

    programs.wezterm.enable = true;

    xdg.configFile."skhd/skhdrc" = lib.mkIf pkgs.stdenv.isDarwin {
      source = ./skhdrc;
    };

    wthueb.services = {
      bartender.enable = pkgs.stdenv.isDarwin;
      raycast.enable = pkgs.stdenv.isDarwin;
    };
  };
}
