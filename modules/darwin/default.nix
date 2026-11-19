{
  config,
  lib,
  pkgs,
  ...
}:
let
  logPath = name: "${config.users.users.${config.system.primaryUser}.home}/Library/Logs/${name}.log";
in
{
  imports =
    (import ../../lib/module-imports.nix { directory = ./.; })
    ++ (import ../../lib/features.nix).importsFor "darwin";

  determinateNix = {
    enable = true;

    determinateNixd = {
      builder.state = "enabled";
      garbageCollector.strategy = "automatic";
    };

    buildMachines =
      let
        mkBuildMachine =
          {
            hostName,
            maxJobs,
            speedFactor,
          }:
          {
            hostName = hostName;
            systems = [ "x86_64-linux" ];
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            maxJobs = maxJobs;
            speedFactor = speedFactor;
            protocol = "ssh-ng";
            sshUser = "wil";
            sshKey = "/Users/wil/.ssh/id_ed25519";
          };
      in
      [
        (mkBuildMachine {
          hostName = "minecraft";
          maxJobs = 4;
          speedFactor = 3;
        })
        (mkBuildMachine {
          hostName = "mbk";
          maxJobs = 4;
          speedFactor = 1;
        })
      ];
    distributedBuilds = true;
    customSettings = {
      trusted-users = [ "wil" ];
      builders-use-substitutes = true;
    };
  };

  users.users.wil = {
    name = "wil";
    home = "/Users/wil";
    # nushell is functionally the default shell, see home/nu.nix
    shell = pkgs.nushell;
  };

  programs.bash.enable = true;

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

  system = {
    activationScripts.power.text = lib.mkAfter ''
      /usr/bin/pmset -b displaysleep 30
      /usr/bin/pmset -c displaysleep 60
    '';

    defaults = {
      controlcenter.BatteryShowPercentage = true;

      dock = {
        autohide = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
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
      trackpad.Clicking = true;

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleInterfaceStyle = "Dark";
        "com.apple.swipescrolldirection" = false; # disable "natural" scrolling
      };

      CustomSystemPreferences = {
        NSGlobalDomain.SLSMenuBarUseBlurredAppearance = true;

        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "/Library/Preferences/com.apple.iokit.AmbientLightSensor"."Automatic Display Enabled" = false;
      };
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # remove all formulae not listed
    };

    taps = [ "vjeantet/tap" ];
    brews = [
      "mas"
      "vjeantet/tap/alerter"
    ];
  };

  launchd.user.envVariables.PATH = [
    "/etc/profiles/per-user/${config.system.primaryUser}/bin"
    "/run/current-system/sw/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  launchd.user.agents.startup = {
    script = ''
      /bin/launchctl setenv PATH ${lib.escapeShellArg config.launchd.user.envVariables.PATH}
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      ${lib.getExe pkgs.defaultbrowser} browser
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
    '';
    serviceConfig = {
      RunAtLoad = true;
      StandardOutPath = logPath "startup";
      StandardErrorPath = logPath "startup";
    };
  };

  home-manager.users.wil.home = {
    sessionPath = lib.optional config.homebrew.enable (config.homebrew.prefix + "/bin");
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
