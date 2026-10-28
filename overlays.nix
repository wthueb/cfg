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
    alcove = prev.alcove.overrideAttrs (old: {
      version = "1.7.7";

      src = final.fetchurl {
        url = "https://download.tryalcove.com/Alcove.dmg";
        hash = "sha256-F8SB/6mvkfx24rqZlflnUFOL8XHl6yvmAsByVfTZROU=";
      };

      nativeBuildInputs = [ final._7zz ];
      passthru = builtins.removeAttrs old.passthru [ "updateScript" ];
      meta = builtins.removeAttrs old.meta [ "changelog" ];
    });
  })
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
