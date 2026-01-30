{ pkgs, lib, ... }:
{
  services.skhd = {
    enable = pkgs.stdenv.isDarwin;
    package =
      let
        extraPackages = [
          pkgs.sketchybar # called in skhdrc, needed for skhd status in bar
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
