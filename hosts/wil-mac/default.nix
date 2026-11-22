{
  self,
  config,
  pkgs,
  ...
}:
let
  logPath = name: "/Users/wil/Library/Logs/${name}.log";
in
{
  environment.systemPackages = with pkgs; [
    #gimp-with-plugins
    litecli
    #sabnzbd
    #teamviewer
  ];

  homebrew = {
    brews = [ ];

    masApps = {
      "Home Assistant" = 1099568401;
      "Xcode" = 497799835;
    };

    greedyCasks = true;

    casks = [
      #"claude-code@latest" # better updates
      "dbeaver-enterprise" # not in nixpkgs
      "docker-desktop" # not in nixpkgs
      "gimp" # no aarch64-darwin
      "google-drive" # not in nixpkgs
      "private-internet-access" # not in nixpkgs
      "sabnzbd" # no aarch64-darwin
      "teamviewer" # no aarch64-darwin
      #"ubersicht" # not in nixpkgs
    ];
  };

  wthueb = {
    desktop.enable = true;
    gc.store.automatic = false;
    keyboard.enable = true;
    services = {
      codex-lb.enable = true;
      #meridian.enable = true;
    };
    video.enable = true;
  };

  system = {
    primaryUser = "wil";
    defaults.dock = {
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
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;
  };

  home-manager.users.wil = {
    launchd.agents = {
      ssh-agent.config = {
        StandardOutPath = logPath "ssh-agent";
        StandardErrorPath = logPath "ssh-agent";
      };
    };
  };

  ids.gids.nixbld = 30000;

  security.sudo.extraConfig = ''
    wil ALL=(ALL) NOPASSWD: ALL
  '';
}
