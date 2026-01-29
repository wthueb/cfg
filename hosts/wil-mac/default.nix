{
  self,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    bartender
    bitwarden-desktop
    brave
    ffmpeg-full
    firefox
    #gimp-with-plugins
    htop
    inetutils
    litecli
    #mouseless
    #plex-desktop
    postman
    qbittorrent
    raycast
    #sabnzbd
    spotify
    sqlite
    #teamviewer
    thunderbird-esr
  ];

  programs.bash.enable = true;

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
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
    };

    greedyCasks = true;

    casks = [
      "cleanshot" # not in nixpkgs
      "dbeaver-enterprise" # not in nixpkgs
      "docker-desktop" # not in nixpkgs
      "gimp" # no aarch64-darwin
      "google-drive" # not in nixpkgs
      "keyboardcleantool" # not in nixpkgs
      "lyn" # not in nixpkgs
      "macfuse" # not in nixpkgs
      "mouseless" # no aarch64-darwin
      "plex" # no aarch64-darwin
      "private-internet-access" # not in nixpkgs
      "sabnzbd" # no aarch64-darwin
      "teamviewer" # no aarch64-darwin
      #"ubersicht" # not in nixpkgs
    ];
  };

  home-manager.users.wil.home.sessionPath = [
    config.homebrew.brewPrefix
  ];

  services = {
    karabiner-elements.enable = true;
    sketchybar.enable = true;
    tailscale.enable = true;
    yabai = {
      enable = true;
      enableScriptingAddition = true;
    };
  };

  launchd.user.agents.raycast = {
    serviceConfig = {
      Program = "${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.user.agents.bartender = {
    serviceConfig = {
      Program = "${pkgs.bartender}/Applications/Bartender 5.app/Contents/MacOS/Bartender 5";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  #launchd.user.agents.bitwarden-desktop = {
  #  serviceConfig = {
  #    Program = "${pkgs.bitwarden-desktop}/bin/bitwarden";
  #    RunAtLoad = true;
  #    KeepAlive = true;
  #  };
  #};

  launchd.user.agents.mouseless = {
    serviceConfig = {
      Program = "/Applications/Mouseless.app/Contents/MacOS/mouseless";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.user.agents.wezterm = {
    serviceConfig = {
      Program = "${pkgs.wezterm}/bin/wezterm-mux-server";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  launchd.user.agents.startup = {
    script = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      ${pkgs.defaultbrowser}/bin/defaultbrowser browser
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
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
          "/Applications/Nix Apps/Brave Browser.app"
          "/Applications/Nix Apps/Thunderbird ESR.app"
          "/System/Applications/Messages.app"
          "${pkgs.discord}/Applications/Discord.app"
          "/Applications/Nix Apps/Spotify.app"
          "${pkgs.wezterm}/Applications/WezTerm.app"
          "/Applications/Plex.app"
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

  users.users.wil = {
    name = "wil";
    home = "/Users/wil";
    # nushell is functionally the default shell, see home/nu.nix
    shell = pkgs.bashInteractive;
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
