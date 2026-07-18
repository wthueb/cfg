{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./services/bartender.nix
    ./services/raycast.nix
  ]
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
          hostName = "drake";
          maxJobs = 2;
          speedFactor = 2;
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

  launchd.user.agents.startup = {
    script = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      ${lib.getExe pkgs.defaultbrowser} browser
      /bin/launchctl setenv ELECTRON_NO_UPDATER 1
    '';
    serviceConfig.RunAtLoad = true;
  };

  home-manager.users.wil.home = {
    sessionPath = lib.optional config.homebrew.enable (config.homebrew.prefix + "/bin");
  };
}
