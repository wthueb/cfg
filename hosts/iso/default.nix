{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  users.users.root.openssh.authorizedKeys.keys = config.users.users.wil.openssh.authorizedKeys.keys;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
}
