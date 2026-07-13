{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wthueb.desktop;
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

    wthueb.services = {
      bartender.enable = true;
      raycast.enable = true;
    };

    environment.systemPackages = with pkgs; [
      alcove
      keyboardcleantool
    ];

    security.accessibilityPrograms = [
      (lib.getExe config.services.yabai.package)
      (lib.getExe pkgs.skhd)
    ];

    homebrew = {
      masApps = {
        "Amphetamine" = 937984704;
      };

      casks = [
        "cleanshot" # not in nixpkgs
        "linearmouse" # not in nixpkgs
        "macfuse" # not in nixpkgs
        "mouseless" # no aarch64-darwin
      ];
    };

    launchd.user.agents.mouseless = {
      serviceConfig = {
        Program = "/Applications/Mouseless.app/Contents/MacOS/mouseless";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };

    launchd.user.agents.wezterm = {
      serviceConfig = {
        Program = lib.getExe' config.home-manager.users.wil.programs.wezterm.package "wezterm-mux-server";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
