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
        claude-code
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
  # NixOS/nixpkgs#523142
  (final: prev: {
    llvmPackages_18 = prev.llvmPackages_18.overrideScope (
      llvmFinal: llvmPrev: {
        compiler-rt-libc = llvmPrev.compiler-rt-libc.overrideAttrs (old: {
          cmakeFlags = (old.cmakeFlags or [ ]) ++ [
            (prev.lib.cmakeBool "COMPILER_RT_BUILD_XRAY" false)
            (prev.lib.cmakeBool "COMPILER_RT_BUILD_LIBFUZZER" false)
            (prev.lib.cmakeBool "COMPILER_RT_BUILD_MEMPROF" false)
            (prev.lib.cmakeBool "COMPILER_RT_BUILD_ORC" false)
          ];
        });
      }
    );
  })
]
