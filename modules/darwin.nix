{
  ...
}:
{
  determinateNix = {
    enable = true;
    buildMachines = [
      {
        hostName = "mbk";
        protocol = "ssh-ng";
        sshUser = "wil";
        sshKey = "/Users/wil/.ssh/id_ed25519";
        systems = [ "x86_64-linux" ];
        maxJobs = 4;
      }
    ];
    distributedBuilds = true;
    customSettings.trusted-users = [ "wil" ];
  };
}
