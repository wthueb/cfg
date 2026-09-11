{
  self,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  meridian = inputs.meridian.packages.${system}.meridian;
  meridianPiScrub = inputs.meridian.legacyPackages.${system}.meridianPlugins.pi-scrub;
  meridianPluginConfig = (pkgs.formats.json { }).generate "meridian-plugins.json" {
    plugins = [
      {
        enabled = true;
        path = meridianPiScrub.path;
      }
    ];
  };
in
{
  environment.systemPackages = with pkgs; [
    #gimp-with-plugins
    inetutils
    litecli
    #plex-desktop
    #sabnzbd
    #teamviewer
  ];

  environment.etc."ssh/sshd_config.d/150-login-path.conf".text =
    let
      home = config.home-manager.users.${config.system.primaryUser}.home;

      path = lib.concatStringsSep ":" (home.sessionPath ++ [ config.environment.systemPath ]);

      # environment.systemPath holds literal $HOME/$USER which SetEnv doesn't expand
      user = config.system.primaryUser;
      fullPath = builtins.replaceStrings [ "$HOME" "$USER" ] [ home.homeDirectory user ] path;
    in
    ''
      SetEnv PATH=${fullPath}
    '';

  homebrew = {
    brews = [
      "pi-coding-agent" # better updates
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
            "${hmApps}/Vesktop.app"
            "${hmApps}/Spotify.app"
            "${hmApps}/WezTerm.app"
            "${hmApps}/Plezy.app"
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

  home-manager.users.wil = {
    home.packages = [ meridian ];

    xdg.configFile."meridian/plugins.json".source = meridianPluginConfig;

    launchd.agents.meridian = {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe meridian) ];
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        ProcessType = "Background";
        ThrottleInterval = 5;
        StandardOutPath = "/Users/wil/Library/Logs/meridian.log";
        StandardErrorPath = "/Users/wil/Library/Logs/meridian.error.log";
      };
    };
  };

  ids.gids.nixbld = 30000;

  security = {
    pam.services.sudo_local.touchIdAuth = true;

    sudo.extraConfig = ''
      wil ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
