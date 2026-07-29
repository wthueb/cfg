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
      bitwarden-desktop
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
  };
}
