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
        systems = [ "x86_64-linux" ];
        maxJobs = 4;
      }
    ];
    distributedBuilds = true;
    customSettings.trusted-users = [ "wil" ];
  };
}
