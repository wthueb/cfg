{
  self,
  pkgs,
  system,
  ...
}:
{
  environment.systemPackages = with pkgs; [
  ];

  services = {
    tailscale.enable = true;
  };

  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
}
