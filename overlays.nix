{ self, inputs }:
[
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
        neovim-unwrapped
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
    # NixOS/nixpkgs#509702
    alcove = prev.alcove.overrideAttrs (old: {
      version = "1.7.2";
      src = final.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gzV/BdLt0cl490cPHPK5Q6S4HRaHI/e4zcOdnM+MVYg=";
      };
    });
  })
]
