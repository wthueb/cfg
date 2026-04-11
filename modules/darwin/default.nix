{ ... }:
{
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
}
