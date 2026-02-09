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
      version = "6.3.1";
      src = final.fetchurl {
        inherit (old.src) name url;
        hash = "sha256-zdVzRUitqF7Bef7Eq/HJYlYTLdEO54zrjI5zUH1pw1Q=";
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
]
