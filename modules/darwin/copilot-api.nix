{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.copilot-api;
in
{
  options.services.copilot-api = {
    enable = lib.mkEnableOption "copilot-api proxy server";

    package = lib.mkPackageOption pkgs "copilot-api" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4141;
      description = "Port to listen on.";
    };

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable verbose logging.";
    };

    accountType = lib.mkOption {
      type = lib.types.enum [
        "individual"
        "business"
        "enterprise"
      ];
      default = "individual";
      description = "GitHub Copilot account type.";
    };

    rateLimit = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Rate limit in seconds between requests.";
    };

    wait = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Wait instead of error when rate limit is hit.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command line arguments to pass to copilot-api.";
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.user.agents.copilot-api = {
      serviceConfig =
        let
          args = [
            "start"
            "--port"
            (toString cfg.port)
            "--account-type"
            cfg.accountType
          ]
          ++ lib.optionals cfg.verbose [ "--verbose" ]
          ++ lib.optionals (cfg.rateLimit != null) [
            "--rate-limit"
            (toString cfg.rateLimit)
          ]
          ++ lib.optionals cfg.wait [ "--wait" ]
          ++ cfg.extraArgs;
        in
        {
          ProgramArguments = [ (lib.getExe cfg.package) ] ++ args;
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/tmp/copilot-api.log";
          StandardErrorPath = "/tmp/copilot-api.err";
        };
    };
  };
}
