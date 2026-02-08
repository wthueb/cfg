{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      max-players = 10;
      gamemode = "survival";
      difficulty = "normal";
      white-list = false;
    };
    jvmOpts = "-Xms6G -Xmx6G -XX:+UseZGC -XX:+ZGenerational";
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.11";
}
