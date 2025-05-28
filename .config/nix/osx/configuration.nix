{
  self,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
  ];

  services = {
    tailscale.enable = true;
  };

  security.sudo.extraConfig = ''
    wil ALL=(ALL) NOPASSWD: ALL
  '';

  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
}
