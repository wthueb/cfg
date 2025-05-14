{
  self,
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  system,
  hostname,
  ...
}:
{
  nixpkgs.overlays = [
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

  environment.variables = {
    "XDG_CONFIG_HOME" = "/Users/wil/.config";
  };

  environment.systemPackages = with pkgs; [
    #inputs.wezterm.packages.${system}.default

    carapace
    dbeaver-bin
    dig
    discord
    dua
    ffmpeg-full
    firefox
    gcc
    gnugrep
    gnumake
    gnused
    gnutar
    google-chrome
    htop
    inetutils
    jc
    jq
    litecli
    nodejs
    #plex-desktop # not supported on aarch64-darwin
    qbittorrent
    raycast
    rsync
    rustup
    #sabnzbd # not supported on aarch64-darwin
    spotify
    sqlite
    starship
    thunderbird-esr
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
      "Xcode" = 497799835;
    };

    casks =
      let
        greedy = name: {
          name = name;
          greedy = true;
        };
      in
      [
        # TODO: try moving these to nixpkgs
        (greedy "bartender")
        (greedy "bitwarden")
        (greedy "docker")
        (greedy "mouseless")
        (greedy "plex")
        (greedy "private-internet-access")
        (greedy "sabnzbd")
        (greedy "stremio")
        (greedy "ubersicht")
      ];
  };

  services = {
    karabiner-elements.enable = true;
    tailscale.enable = true;
    #sketchybar.enable = true;
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
    command = "${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.user.agents.mouseless = {
    command = "/Applications/Mouseless.app/Contents/MacOS/mouseless";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  system = {
    defaults = {
      dock = {
        autohide = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps = [
          "${pkgs.google-chrome}/Applications/Google Chrome.app"
          "${pkgs.thunderbird-esr}/Applications/Thunderbird ESR.app"
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
      open -a "${pkgs.google-chrome}/Applications/Google Chrome.app/" --args --make-default-browser
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
