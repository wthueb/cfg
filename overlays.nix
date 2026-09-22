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
  })
  (final: prev: {
    plezy = inputs.nixpkgs-fork.legacyPackages.${final.stdenv.hostPlatform.system}.plezy;
  })
]
