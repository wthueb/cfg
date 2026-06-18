{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.wthueb.desktop;
in
{
  options.wthueb.desktop.enable = lib.mkEnableOption "desktop GUI applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
      nil
      nixfmt
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
