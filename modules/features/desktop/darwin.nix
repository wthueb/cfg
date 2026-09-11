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
    services.skhd = {
      enable = true;
      package =
        let
          # called in skhdrc, needed for skhd status in bar
          extraPackages = [
            pkgs.sketchybar
            pkgs.wezterm
            pkgs.yabai
          ];
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath extraPackages)
          ];
        in
        pkgs.symlinkJoin {
          name = "skhd";
          paths = [ pkgs.skhd ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/skhd ${lib.escapeShellArgs makeWrapperArgs}
          '';
          inherit (pkgs.skhd) meta;
        };
      skhdConfig = builtins.readFile ./skhdrc;
    };

    services.karabiner-elements.enable = true;

    wthueb.security.tcc =
      let
        karabinerPackage = config.services.karabiner-elements.package;
        weztermPackage = config.home-manager.users.${config.system.primaryUser}.programs.wezterm.package;
        weztermMuxServer = lib.getExe' weztermPackage "wezterm-mux-server";
      in
      {
        enable = true;

        permissions = {
          accessibility = [
            pkgs.runtimeShell
            (lib.getExe pkgs.skhd)
            (lib.getExe pkgs.yabai)
          ];

          inputMonitoring = [
            "${karabinerPackage}/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_grabber"
            "${karabinerPackage}/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_observer"
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
      masApps = {
        "Amphetamine" = 937984704;
        "Bitwarden" = 1352778147;
        "WhatsApp Messenger" = 310633997;
      };

      casks = [
        "cleanshot" # not in nixpkgs
        "linearmouse" # not in nixpkgs
        "macfuse" # not in nixpkgs
        "mouseless" # no aarch64-darwin
      ];
    };

    launchd.user.agents = {
      activate_karabiner_system_ext.serviceConfig = logConfig "activate_karabiner_system_ext";
      karabiner_session_monitor.serviceConfig = logConfig "karabiner_session_monitor";
      skhd.serviceConfig = logConfig "skhd";

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
