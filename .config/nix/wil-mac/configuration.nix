{
  self,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      spotify = prev.spotify.overrideAttrs (old: {
        src = pkgs.fetchurl {
          inherit (old.src) url;
          hash = "sha256-a3LPFX3/f58fuaEJmzcpsgI27yTaRltwftwOuJBN+nQ=";
        };
      });
    })
  ];

  environment.variables = {
    "XDG_CONFIG_HOME" = "/Users/wil/.config";
  };

  environment.systemPackages = with pkgs; [
    #inputs.wezterm.packages.${pkgs.stdenv.currentSystem}.default

    bartender
    bitwarden-desktop
    carapace
    dbeaver-bin
    dig
    discord
    dua
    ffmpeg-full
    firefox
    #gcc
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
    python3
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

    taps = [ ];

    brews = [
      "mas"
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
        (greedy "docker")
        (greedy "mouseless")
        (greedy "plex")
        (greedy "private-internet-access")
        (greedy "sabnzbd")
        (greedy "stremio")
        #(greedy "ubersicht")
      ];
  };

  services = {
    karabiner-elements = {
      enable = true;
      package = pkgs.karabiner-elements.overrideAttrs (old: {
        version = "14.13.0";

        src = pkgs.fetchurl {
          inherit (old.src) url;
          hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
        };

        dontFixup = true;
      });
    };
    tailscale.enable = true;
    sketchybar.enable = true;
    skhd.enable = true;
    yabai = {
      enable = true;
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

  launchd.user.agents.bartender = {
    command = "\"${pkgs.bartender}/Applications/Bartender 5.app/Contents/MacOS/Bartender 5\"";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.user.agents.bitwarden = {
    command = "${pkgs.bitwarden}/bin/bitwarden";
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

  launchd.user.agents.startup = {
    script = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      ${pkgs.defaultbrowser}/bin/defaultbrowser chrome
      open -a "${pkgs.google-chrome}/Applications/Google Chrome.app/" --args --make-default-browser
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
      ${pkgs.tldr}/bin/tldr --update
    '';
    serviceConfig.RunAtLoad = true;
  };

  system = {
    primaryUser = "wil";
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
