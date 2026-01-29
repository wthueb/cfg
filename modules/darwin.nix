{
  ...
}:
{
  determinateNix = {
    enable = true;
    buildMachines = [
      # {
      #   hostName = "mbk";
      #   protocol = "ssh-ng";
      #   sshUser = "wil";
      #   sshKey = "/Users/wil/.ssh/id_ed25519";
      #   systems = [ "x86_64-linux" ];
      #   maxJobs = 4;
      # }
      {
        hostName = "drake";
        protocol = "ssh-ng";
        sshUser = "wil";
        sshKey = "/Users/wil/.ssh/id_ed25519";
        systems = [ "x86_64-linux" ];
        maxJobs = 2;
      }
    ];
    distributedBuilds = true;
    customSettings.trusted-users = [ "wil" ];
  };
}
