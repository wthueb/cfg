{ self, inputs }:
[
  (final: prev: {
    copilot-api = self.packages.${final.stdenv.hostPlatform.system}.copilot-api;
    keyboardcleantool = self.packages.${final.stdenv.hostPlatform.system}.keyboardcleantool;
  })
  (
    final: prev:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      inherit (unstable)
        bartender
        inetutils
        neovim
        nushell
        nushellPlugins
        opencode
        starship
        #wezterm
        yabai
        ;
    }
  )
  (final: prev: {
    wezterm = inputs.wezterm.packages.${final.stdenv.hostPlatform.system}.default;
  })
  (final: prev: {
    karabiner-elements = prev.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";
      src = final.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };
      dontFixup = true;
    });
  })
  (final: prev: {
    # DeterminateSystems/nix-src#345
    nil =
      let
        pkgs = prev;
        lib = pkgs.lib;
        extraPackages = [ pkgs.nix ];
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath extraPackages)
        ];
      in
      pkgs.symlinkJoin {
        name = pkgs.nil.pname;
        paths = [ pkgs.nil ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/${pkgs.nil.pname} ${lib.escapeShellArgs makeWrapperArgs}
        '';
        inherit (pkgs.nil) meta;
      };
  })
]
