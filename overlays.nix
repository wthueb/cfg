{ inputs }:
[
  (final: prev: {
    inherit (inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system})
      carapace
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
    nushell = prev.nushell.overrideAttrs (old: {
      doCheck = false;
    });
  })
  (final: prev: {
    nushellPlugins = prev.nushellPlugins // {
      desktop_notifications = prev.nushellPlugins.desktop_notifications.overrideAttrs (old: {
        meta.platforms = prev.lib.platforms.linux ++ prev.lib.platforms.darwin;
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
