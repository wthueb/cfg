{ pkgs, lib, ... }:
{
  services.skhd = {
    enable = pkgs.stdenv.isDarwin;
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
    config = ./skhdrc;
  };
}
