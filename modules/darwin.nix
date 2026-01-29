{
  ...
}:
{
  determinateNix = {
    enable = true;
    buildMachines = [
      # {
      #   hostName = "mbk";
      #   systems = [ "x86_64-linux" ];
      #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      #   maxJobs = 4;
      #   protocol = "ssh-ng";
      #   sshUser = "wil";
      #   sshKey = "/Users/wil/.ssh/id_ed25519";
      # }
      {
        hostName = "drake";
        systems = [ "x86_64-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        maxJobs = 2;
        protocol = "ssh-ng";
        sshUser = "wil";
        sshKey = "/Users/wil/.ssh/id_ed25519";
      }
    ];
    distributedBuilds = true;
    customSettings.trusted-users = [ "wil" ];
  };
}
