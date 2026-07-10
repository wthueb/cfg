{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.video;
in
{
  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        ffmpeg-full
        imagemagick
        mediainfo
        yt-dlp
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        filebot
      ];

    xdg.dataFile."filebot/data/.license".source =
      config.lib.file.mkOutOfStoreSymlink config.sops.secrets.filebot.path;

    sops.secrets.filebot = {
      sopsFile = ../../../secrets/filebot.psm;
      format = "binary";
    };
  };
}
