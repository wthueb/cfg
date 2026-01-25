{ inputs }:
[
  (
    final: prev:
    let
      unstable = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      inherit (unstable)
        carapace
        neovim
        nushell
        opencode
        starship
        #wezterm
        yabai
        ;
    }
  )
  (final: prev: {
    deploy-rs = inputs.deploy-rs.packages.${final.stdenv.hostPlatform.system}.default;
  })
  (final: prev: {
    wezterm = inputs.wezterm.packages.${final.stdenv.hostPlatform.system}.default;
  })
  (final: prev: {
    nushellPlugins = prev.nushellPlugins // {
      desktop_notifications = prev.nushellPlugins.desktop_notifications.overrideAttrs (old: rec {
        version = "0.109.1";
        src = final.fetchFromGitHub {
          owner = "FMotalleb";
          repo = "nu_plugin_desktop_notifications";
          tag = "v${version}";
          hash = "sha256-eNdaaOgQWd5qZQG9kypzpMsHiKX7J5BXPSsNLJYCVTo=";
        };
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-Mo+v3725jVNTCy7qjvTnDDN2JSAI48tpPCoQoewo4wM=";
        };
        meta = old.meta // {
          platforms = final.lib.platforms.linux ++ final.lib.platforms.darwin;
        };
      });
    };
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
