{ inputs }:
[
  (final: prev: {
    inherit (inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system})
      inetutils
      neovim
      nushell
      nushellPlugins
      opencode
      starship
      #wezterm
      yabai
      ;
  })
  (final: prev: {
    bartender = prev.bartender.overrideAttrs (old: {
      version = "6.4.1";
      src = final.fetchurl {
        inherit (old.src) name url;
        hash = "sha256-UbBymSFwhk7sTCQP4R9XMBKE0VuaG1J+Y4OGIsMttWc=";
      };
    });
  })
  (final: prev: {
    nushell = prev.nushell.overrideAttrs (old: {
      doCheck = false;
    });
  })
  (final: prev: {
    nushellPlugins = prev.nushellPlugins // {
      desktop_notifications = prev.nushellPlugins.desktop_notifications.overrideAttrs (old: {
        meta = old.meta // {
          platforms = old.meta.platforms ++ final.lib.platforms.darwin;
        };
      });
    };
  })
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
