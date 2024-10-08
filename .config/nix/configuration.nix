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
    ];
  };

  environment.systemPackages = [
    inputs.nil.packages.${pkgs.system}.nil

    #pkgs.plex-desktop # aarch64-darwin not supported

    pkgs.stable.wezterm # wez/wezterm#5990

    pkgs.bashInteractive
    pkgs.bat
    pkgs.btop
    pkgs.carapace
    pkgs.coreutils
    pkgs.curl
    pkgs.delta
    pkgs.dig
    pkgs.discord
    pkgs.dua
    pkgs.fd
    pkgs.ffmpeg-full
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
    pkgs.google-cloud-sdk
    pkgs.hyperfine
    pkgs.inetutils
    pkgs.jc
    pkgs.jq
    pkgs.less
    pkgs.litecli
    pkgs.neofetch
    pkgs.neovim
    pkgs.nixfmt-rfc-style
    pkgs.nodejs_20
    pkgs.nushell
    pkgs.qbittorrent
    pkgs.raycast
    pkgs.rclone
    pkgs.ripgrep
    pkgs.rsync
    pkgs.rustup
    pkgs.spotify
    pkgs.sqlite
    pkgs.starship
    pkgs.tldr
    pkgs.tmux
    pkgs.tree
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
    };

    casks = [
      # TODO: go through apps and add them here
      "bartender"
      "bitwarden"
      "dbeaver-community"
      "docker"
      #"firefox"
      #"google-chrome"
      "hammerspoon"
      "karabiner-elements"
      "plex"
    ];
  };

  environment = {
    shells = [
      pkgs.bash
      pkgs.fish
      pkgs.nushell
    ];
    loginShell = pkgs.nushell;
    variables = {
      XDG_CONFIG_HOME = "/Users/wil/.config";
    };
  };

  programs = {
    nix-index.enable = true;
  };

  services = {
    nix-daemon.enable = true;
    # karabiner-elements.enable = true;
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
    (pkgs.nerdfonts.override {
      fonts = [
        "SourceCodePro"
        "FiraCode"
      ];
    })
  ];

  system = {
    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };
    };

    # disable electron apps from automatically checking for updates
    activationScripts.extraUserActivation.text = ''
      launchctl setenv ELECTRON_NO_UPDATER 1
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
