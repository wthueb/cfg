let
  greedy = name: {
    name = name;
    greedy = true;
  };
in
{
  self,
  pkgs,
  inputs,
  hostname,
  ...
}:
{
  nix = {
    enable = true;
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

  environment.systemPackages = with pkgs; [
    #inputs.wezterm.packages.${pkgs.system}.default

    bashInteractive
    bat
    carapace
    coreutils
    curl
    #dbeaver-bin broken currently
    delta
    dig
    discord
    dua
    fd
    ffmpeg-full
    #firefox aarch64-darwin not supported
    fzf
    gcc
    gh
    git
    gnugrep
    gnumake
    gnused
    gnutar
    google-chrome
    htop
    inetutils
    jc
    jq
    less
    litecli
    neovim
    nil
    nixfmt-rfc-style
    nodejs
    nushell
    #plex-desktop aarch64-darwin not supported
    qbittorrent
    raycast
    ripgrep
    rsync
    rustup
    #sabnzbd aarch64-darwin not supported
    spotify
    sqlite
    starship
    #thunderbird aarch64-darwin not supported
    tldr
    tmux
    tree
    wezterm
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
      "Tailscale" = 1475387142;
      "Xcode" = 497799835;
    };

    casks = [
      # TODO: try moving these to nixpkgs
      (greedy "bartender")
      (greedy "bitwarden")
      (greedy "dbeaver-community")
      (greedy "docker")
      (greedy "firefox")
      (greedy "hammerspoon")
      (greedy "mailmate@beta")
      (greedy "mouseless")
      (greedy "plex")
      (greedy "private-internet-access")
      (greedy "sabnzbd")
      (greedy "stremio")
      (greedy "thunderbird@esr")
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
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    nix-index.enable = true;
    direnv.enable = true;
  };

  services = {
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

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
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
        "com.apple.swipescrolldirection" = false; # disable "natural" scrolling
      };

      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };

    # disable electron apps from automatically checking for updates
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      /run/current-system/sw/bin/nix run nixpkgs#defaultbrowser -- chrome
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
      ${pkgs.tldr}/bin/tldr --update
    '';

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;
  };

  ids.gids.nixbld = 30000;

  networking = {
    hostName = hostname;
  };

  security = {
    accessibilityPrograms = [
      "${pkgs.skhd}/bin/skhd"
      "${pkgs.yabai}/bin/yabai"
    ];

    pam.services.sudo_local.touchIdAuth = true;

    sudo.extraConfig = ''
      wil ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
