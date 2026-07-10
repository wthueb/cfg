{
  config,
  lib,
  ...
}:
let
  cfg = config.wthueb.video;
in
{
  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "filebot"
    ];
  };
}
