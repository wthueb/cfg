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
      postman
      spotify
      thunderbird-esr-bin
      winbox
    ];

    fonts.fontconfig.enable = true;

    programs = {
      discord = {
        enable = true;
        settings = {
          SKIP_HOST_UPDATE = true;
          DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
        };
      };
      wezterm.enable = true;
    };
  };
}
