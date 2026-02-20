{
  config,
  pkgs,
  lib,
  ...
}:
{
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
            title = "(Co(py|nnect)|Move|Info|Pref)";
            manage = "off";
            layer = "above";
          }
          {
            app = "System Settings";
            manage = "off";
            sticky = true;
          }
          {
            app = "App Store";
            manage = "off";
          }
          {
            app = "Bitwarden";
            manage = "off";
          }
          {
            app = "Digital Color Meter";
            manage = "off";
            sticky = true;
            layer = "above";
          }
          {
            app = "IINA";
            manage = "off";
          }
          {
            app = "Raycast";
            manage = "off";
          }
          {
            title = "^Picture in Picture$";
            manage = "off";
            sticky = true;
          }
          {
            app = "GIMP";
            notitle = "(^GNU Image Manipulation Program)|(GIMP)$";
            manage = "off";
          }
          {
            app = "CleanShot X";
            manage = "off";
          }
          {
            app = "Google Drive";
            manage = "off";
          }
          {
            app = "Lyn";
            title = "Preferences$";
            manage = "off";
          }
          {
            app = "DBeaver";
            notitle = "^DBeaver";
            manage = "off";
          }
        ];

        ruleAttrToArg =
          name: value:
          if name == "notitle" then
            "title!=${lib.escapeShellArg value}"
          else
            "${name}=${lib.escapeShellArg value}";

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

  security.accessibilityPrograms = [ (lib.getExe config.services.yabai.package) ];
}
