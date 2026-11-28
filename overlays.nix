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
        carapace
        neovim
        neovim-unwrapped
        nil
        nushell
        nushellPlugins
        plezy
        raycast
        starship
        wezterm
        yabai
        ;
    }
  )
  (final: prev: {
    yabai = prev.yabai.overrideAttrs (
      finalAttrs: old: {
        version = "7.3.4";

        src = final.fetchFromGitHub {
          owner = "Christian-SC26";
          repo = "yabai";
          tag = "v${finalAttrs.version}";
          hash = "sha256-hHgPo8AQTxPnYlO1vPrBgDigzGHu7XHFqJywX57LK5s=";
        };

        meta = old.meta // {
          homepage = "https://github.com/Christian-SC26/yabai";
          changelog = "https://github.com/Christian-SC26/yabai/blob/v${finalAttrs.version}/CHANGELOG.md";
        };
      }
    );
  })
  (final: prev: {
    cadvisor = prev.cadvisor.overrideAttrs (
      finalAttrs: _: {
        version = "0.57.0";

        src = final.fetchFromGitHub {
          owner = "google";
          repo = "cadvisor";
          rev = "v${finalAttrs.version}";
          hash = "sha256-9HeiSO6yedDpv6YUAdZU7CqfGkun4ugZs4RbSZ51MPU=";
        };

        vendorHash = "sha256-zPn7CqSw+SW0Air5dEs+/wNwNAJjd5XX7wC3hrOHJQU=";
      }
    );
  })
  (final: prev: {
    grafana-loki = prev.grafana-loki.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace vendor/github.com/grafana/dskit/tracing/otel.go \
          --replace-fail '"go.opentelemetry.io/otel/semconv/v1.39.0"' '"go.opentelemetry.io/otel/semconv/v1.43.0"'
      '';
    });
  })
  (final: prev: {
    plezy = prev.plezy.overrideAttrs (old: {
      version = "2.23.0";

      src = final.fetchurl {
        url = "https://github.com/edde746/plezy/releases/download/2.23.0/plezy-macos.dmg";
        hash = "sha256-6s3PZZ4jbD4oVY/KkSsj4HBIbl9vxEeJ8o6gSbXojpQ=";
      };
    });
  })
  (final: prev: {
    # web.archive.org tweaks out sometimes
    filebot = prev.filebot.overrideAttrs (old: {
      src = final.fetchurl {
        url = "https://get.filebot.net/filebot/FileBot_${old.version}/FileBot_${old.version}-portable.tar.xz";
        hash = old.src.outputHash;
      };
    });
  })
]
