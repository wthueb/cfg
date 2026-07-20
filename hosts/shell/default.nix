{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./hardware.nix ];

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
  ];

  services.traefik = {
    enable = true;
  };

  system.stateVersion = "26.05";
}
