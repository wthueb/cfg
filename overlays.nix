{ self, inputs }:
[
  (
    final: prev:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-39.8.10" ];
      };
    in
    {
      inherit (unstable)
        alcove
        bartender
        inetutils
        neovim
        neovim-unwrapped
        nil
        nushell
        nushellPlugins
        starship
        yabai
        ;

      # Root fix: NixOS/nixpkgs#536365 ("ld64: disable hardening again", merged to
      # staging-next 2026-07-15). Drop this once that reaches nixpkgs-unstable.
      bitwarden-desktop =
        if unstable.stdenv.hostPlatform.isDarwin then
          unstable.bitwarden-desktop.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ unstable.llvmPackages.lld ];
            env = (old.env or { }) // {
              NIX_CFLAGS_LINK = "-fuse-ld=lld";
            };
          })
        else
          unstable.bitwarden-desktop;
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
]
