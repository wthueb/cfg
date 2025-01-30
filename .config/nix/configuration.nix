{
  self,
  pkgs,
  inputs,
  ...
}:
{
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      substituters = [ "https://cache.nixos.org" ];
    };
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    #overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
    overlays = [
      (final: prev: {
        stable = import inputs.nixpkgs-stable {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
      })
      (final: prev: {
        karabiner-elements = prev.karabiner-elements.overrideAttrs (old: {
          version = "14.13.0";
          src = prev.fetchurl {
            inherit (old.src) url;
            hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
          };
        });
      })
    ];
  };

  environment.systemPackages = [
    #inputs.wezterm.packages.${pkgs.system}.default

    pkgs.bashInteractive
    pkgs.bat
    pkgs.btop
    pkgs.carapace
    pkgs.coreutils
    pkgs.curl
    #pkgs.dbeaver-bin broken currently
    pkgs.delta
    pkgs.dig
    pkgs.discord
    pkgs.dua
    pkgs.fd
    pkgs.ffmpeg-full
    #pkgs.firefox aarch64-darwin not supported
    pkgs.fish
    pkgs.fzf
    pkgs.gcc
    pkgs.gh
    pkgs.git
    pkgs.gnugrep
    pkgs.gnumake
    pkgs.gnused
    pkgs.gnutar
    pkgs.go
    pkgs.google-chrome
    pkgs.google-cloud-sdk
    pkgs.hyperfine
    pkgs.inetutils
    pkgs.jc
    pkgs.jq
    pkgs.less
    pkgs.litecli
    pkgs.neofetch
    pkgs.neovim
    pkgs.nil
    pkgs.nixfmt-rfc-style
    pkgs.nodejs_20
    pkgs.nushell
    #pkgs.plex-desktop aarch64-darwin not supported
    pkgs.qbittorrent
    pkgs.raycast
    pkgs.rclone
    pkgs.ripgrep
    pkgs.rsync
    pkgs.rustup
    #pkgs.sabnzbd aarch64-darwin not supported
    pkgs.spotify
    pkgs.sqlite
    pkgs.starship
    #pkgs.thunderbird aarch64-darwin not supported
    pkgs.tldr
    pkgs.tmux
    pkgs.tree
    pkgs.wezterm
    pkgs.yt-dlp
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # remove all formulae not listed below
    };

    taps = [
      "homebrew/services"
      "mongodb/homebrew-brew"
    ];

    brews = [
      {
        name = "mongodb-community";
        start_service = true;
        restart_service = "changed";
      }
      "mas"
      "pyenv"

      # python build deps
      "openssl"
      "readline"
      "sqlite3"
      "xz"
      "zlib"
      "tcl-tk"
    ];

    masApps = {
      "Xcode" = 497799835;
      "Tailscale" = 1475387142;
    };

    casks = [
      # TODO: try moving these to nixpkgs
      "bartender"
      "bitwarden"
      "dbeaver-community"
      "docker"
      "firefox"
      "hammerspoon"
      "plex"
      "sabnzbd"
      "thunderbird@esr"
    ];
  };

  environment = {
    shells = [
      pkgs.bash
      pkgs.fish
      pkgs.nushell
    ];
    variables = {
      XDG_CONFIG_HOME = "/Users/wil/.config";
    };
  };

  programs = {
    nix-index.enable = true;
  };

  services = {
    nix-daemon.enable = true;
    karabiner-elements.enable = true;
    sketchybar.enable = true;
    skhd = {
      enable = true;
      package = pkgs.skhd;
    };
    yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
    };
  };

  launchd.user.agents.raycast = {
    serviceConfig.ProgramArguments = [ "/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast" ];
    serviceConfig.RunAtLoad = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.nerd-fonts.fira-code
  ];

  system = {
    defaults = {
      dock = {
        autohide = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps = [
          "${pkgs.google-chrome}/Applications/Google Chrome.app"
          "/Applications/Thunderbird.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Messages.app"
          "${pkgs.discord}/Applications/Discord.app"
          "${pkgs.spotify}/Applications/Spotify.app"
          "${pkgs.wezterm}/Applications/WezTerm.app"
          "/Users/wil/Applications/Chrome Apps.localized/plex.app"
        ];
        persistent-others = [ ];
        show-process-indicators = true;
        show-recents = false;
        tilesize = 48;
        wvous-tl-corner = 1; # disabled
        wvous-tr-corner = 1; # disabled
        wvous-bl-corner = 1; # disabled
        wvous-br-corner = 1; # disabled
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };

      loginwindow.GuestEnabled = false;

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
      };
    };

    # disable electron apps from automatically checking for updates
    activationScripts.postUserActivation.text = ''
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
      ${pkgs.tldr}/bin/tldr --update
    '';

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
  };

  security = {
    accessibilityPrograms = [
      "${pkgs.skhd}/bin/skhd"
      "${pkgs.yabai}/bin/yabai"
    ];

    pam.enableSudoTouchIdAuth = true;

    sudo.extraConfig = ''
      wil ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
