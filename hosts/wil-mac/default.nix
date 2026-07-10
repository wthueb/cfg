{
  self,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    #gimp-with-plugins
    inetutils
    litecli
    #plex-desktop
    #sabnzbd
    sqlite
    #teamviewer
  ];

  homebrew = {
    brews = [
      "opencode" # better updates
    ];

    masApps = {
      "Home Assistant" = 1099568401;
    };

    greedyCasks = true;

    casks = [
      "claude-code@latest" # better updates
      "dbeaver-enterprise" # not in nixpkgs
      "docker-desktop" # not in nixpkgs
      "gimp" # no aarch64-darwin
      "google-drive" # not in nixpkgs
      "lyn" # not in nixpkgs
      "plex" # no aarch64-darwin
      "private-internet-access" # not in nixpkgs
      "sabnzbd" # no aarch64-darwin
      "teamviewer" # no aarch64-darwin
      #"ubersicht" # not in nixpkgs
    ];
  };

  wthueb = {
    desktop.enable = true;
    video.enable = true;
  };

  #launchd.user.agents.bitwarden-desktop = {
  #  serviceConfig = {
  #    Program = "${lib.getExe pkgs.bitwarden-desktop}/bin/bitwarden";
  #    RunAtLoad = true;
  #    KeepAlive = true;
  #  };
  #};

  system = {
    primaryUser = "wil";
    defaults = {
      dock = {
        autohide = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps =
          let
            hmApps = "${config.home-manager.users.wil.home.homeDirectory}/${config.home-manager.users.wil.targets.darwin.copyApps.directory}";
          in
          [
            "${hmApps}/Brave Browser.app"
            "${hmApps}/Thunderbird.app"
            "/System/Applications/Messages.app"
            "${hmApps}/Discord.app"
            "${hmApps}/Spotify.app"
            "${hmApps}/WezTerm.app"
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

  ids.gids.nixbld = 30000;

  security = {
    pam.services.sudo_local.touchIdAuth = true;

    sudo.extraConfig = ''
      wil ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
