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
  config = lib.mkIf cfg.enable {
    services.yabai = {
      enable = true;

      package =
        let
          extraPackages = [ pkgs.sketchybar ];
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath extraPackages)
          ];
        in
        pkgs.symlinkJoin {
          name = "yabai";
          paths = [ pkgs.yabai ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/yabai ${lib.escapeShellArgs makeWrapperArgs}
          '';
          inherit (pkgs.yabai) meta;
        };

      enableScriptingAddition = true;

      config = {
        debug_output = "off";
        layout = "bsp";
        split_ratio = 0.5;
        split_type = "auto";
        auto_balance = "on";
        top_padding = 0;
        bottom_padding = 0;
        left_padding = 0;
        right_padding = 0;
        window_gap = 0;
        mouse_follows_focus = "off";
        focus_follows_mouse = "off";
        window_opacity = "off";
        active_window_opacity = 1.0;
        normal_window_opacity = 0.9;
        window_shadow = "float";
        insert_feedback_color = "0xffd75f5f";
        window_origin_display = "default";
        window_placement = "second_child";
        window_zoom_persist = "on";
        window_animation_duration = 0.0;
        window_opacity_duration = 0.0;
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
      };

      extraConfig =
        let
          rules = [
            {
              app = "Finder";
              title = "^(Co(py|nnect)|Move|Info|Pref|Trash)$";
              manage = false;
              sub-layer = "above";
            }
            {
              app = "System Settings";
              manage = false;
              sticky = true;
            }
            {
              app = "App Store";
              manage = false;
            }
            {
              app = "Bitwarden";
              manage = false;
            }
            {
              app = "Digital Color Meter";
              manage = false;
              sticky = true;
              sub-layer = "above";
            }
            {
              app = "IINA";
              manage = false;
            }
            {
              app = "Raycast";
              manage = false;
            }
            {
              title = "^Picture in Picture$";
              manage = false;
              sticky = true;
            }
            {
              app = "GIMP";
              "title!" = "^(GNU Image Manipulation Program|GIMP)$";
              manage = false;
            }
            {
              app = "CleanShot X";
              manage = false;
            }
            {
              app = "Google Drive";
              manage = false;
            }
            {
              app = "Lyn";
              title = "Preferences$";
              manage = false;
            }
            {
              app = "DBeaver";
              "title!" = "^DBeaver";
              manage = false;
            }
          ];

          toValue = v: if builtins.isBool v then (if v then "on" else "off") else toString v;

          ruleAttrToArg = name: value: "${name}=${lib.escapeShellArg (toValue value)}";

          rulesConfig = lib.concatStringsSep "\n" (
            map (
              rule: "yabai -m rule --add " + (lib.concatStringsSep " " (lib.mapAttrsToList ruleAttrToArg rule))
            ) rules
          );
        in
        ''
          sudo yabai --load-sa

          yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

          yabai -m signal --add event=window_title_changed active=yes action="sketchybar --trigger title_change"

          ${rulesConfig}

          SPACEBAR_HEIGHT=$(sketchybar --query bar | jq .height)
          yabai -m config external_bar "all:''\${SPACEBAR_HEIGHT}:0"
        '';
    };
  };
}
