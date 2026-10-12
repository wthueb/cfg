{ lib, ... }:
{
  options.wthueb.gc = {
    enable = lib.mkEnableOption "Scheduled Nix store garbage collection and generation pruning";

    store.automatic = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run scheduled Nix store garbage collection independently of Determinate's automatic collector.";
    };

    generations = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Prune old system and Home Manager generations without collecting store paths.";
      };

      olderThan = lib.mkOption {
        type = lib.types.strMatching "[1-9][0-9]*d";
        default = "14d";
        example = "30d";
        description = "Age threshold for generation pruning, in days. The current generation is always retained.";
      };
    };
  };
}
