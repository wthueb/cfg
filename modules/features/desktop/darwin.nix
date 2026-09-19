{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.desktop;
  logPath = name: "${config.users.users.${config.system.primaryUser}.home}/Library/Logs/${name}.log";
  logConfig = name: {
    StandardOutPath = logPath name;
    StandardErrorPath = logPath name;
  };
in
{
  imports = [ ./yabai.nix ];

  config = lib.mkIf cfg.enable {
    wthueb.security.tcc =
      let
        weztermPackage = config.home-manager.users.${config.system.primaryUser}.programs.wezterm.package;
        weztermMuxServer = lib.getExe' weztermPackage "wezterm-mux-server";
      in
      {
        enable = true;

        permissions = {
          accessibility = [
            pkgs.runtimeShell
            (lib.getExe pkgs.yabai)
          ];

          contacts = [ pkgs.runtimeShell ];
          photos = [ weztermMuxServer ];

          appleEvents = [
            {
              client = weztermMuxServer;
              indirectObject = {
                identifier = "com.apple.systemevents";
                path = "/System/Library/CoreServices/System Events.app";
              };
            }
          ];
        };
      };

    environment.systemPackages = with pkgs; [
      alcove
      keyboardcleantool
    ];

    homebrew = {
      taps = [
        {
          name = "jackielii/tap";
          trusted = true;
        }
      ];

      masApps = {
        "Amphetamine" = 937984704;
        "Bitwarden" = 1352778147;
        "WhatsApp Messenger" = 310633997;
      };

      casks = [
        "cleanshot" # not in nixpkgs
        "jackielii/tap/skhd-zig"
        "linearmouse" # not in nixpkgs
        "macfuse" # not in nixpkgs
        "mouseless" # no aarch64-darwin
      ];
    };

    launchd.user.agents = {
      mouseless.serviceConfig = logConfig "mouseless" // {
        Program = "/Applications/Mouseless.app/Contents/MacOS/mouseless";
        RunAtLoad = true;
        KeepAlive = true;
      };

      wezterm.serviceConfig = logConfig "wezterm" // {
        # Program = lib.getExe' config.home-manager.users.wil.programs.wezterm.package "wezterm-mux-server";
        # using the home-manager profile path so the service doesn't get reloaded during upgrades
        Program = "/etc/profiles/per-user/${config.system.primaryUser}/bin/wezterm-mux-server";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
