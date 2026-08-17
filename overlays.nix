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
        alcove
        bartender
        gh-stack
        inetutils
        neovim
        neovim-unwrapped
        nil
        nushell
        nushellPlugins
        plezy
        starship
        wezterm
        yabai
        ;
    }
  )
  (final: prev: {
    # web.archive.org having trouble
    filebot = prev.filebot.overrideAttrs (old: {
      src = final.fetchurl {
        url = "https://get.filebot.net/filebot/FileBot_${old.version}/FileBot_${old.version}-portable.tar.xz";
        hash = old.src.outputHash;
      };
    });

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
