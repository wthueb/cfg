{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.services.skhd;
  home = config.home.homeDirectory;
  configuration = pkgs.writeText "skhdrc" cfg.config;
in
{
  options.wthueb.services.skhd = {
    enable = lib.mkEnableOption "the skhd command hotkey agent";

    package = lib.mkPackageOption pkgs "skhd-zig" { };

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "skhd hotkey configuration.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages available to hotkey commands.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables for hotkey commands.";
    };

    logDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${home}/Library/Logs";
      defaultText = lib.literalExpression "\"\${config.home.homeDirectory}/Library/Logs\"";
      description = "Directory for skhd logs.";
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || pkgs.stdenv.isDarwin;
          message = "wthueb.services.skhd is only supported on macOS";
        }
      ];
    }
    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      xdg.configFile."skhd/skhdrc".source = configuration;

      launchd.agents.skhd = {
        enable = true;
        config = {
          EnvironmentVariables = {
            HOME = home;
            USER = config.home.username;
            SHELL = lib.getExe pkgs.bashInteractive;
            PATH = lib.makeBinPath ([ cfg.package ] ++ cfg.extraPackages);
          }
          // cfg.environment;
          ProgramArguments = [
            (lib.getExe cfg.package)
            "--config"
            (toString configuration)
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${cfg.logDirectory}/skhd.log";
          StandardErrorPath = "${cfg.logDirectory}/skhd.log";
        };
      };
    })
  ];
}
