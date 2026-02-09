{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = config.sops.secrets.minecraft-environment.path;

    servers.vanilla = {
      enable = true;
      autoStart = true;
      openFirewall = true;

      package = pkgs.vanillaServers.vanilla;

      operators = {
        wi1h = {
          uuid = "806957cb-7383-4ed4-a7a9-d01122b63c91";
          level = 4;
          bypassesPlayerLimit = true;
        };
      };

      serverProperties = {
        server-port = 25565;
        max-players = 10;
        gamemode = "survival";
        difficulty = "normal";
        white-list = false;
        enable-rcon = true;
        "rcon.password" = "@rcon_password@";
      };

      jvmOpts = "-Xms6G -Xmx6G -XX:+UseZGC -XX:+ZGenerational";
    };
  };

  sops.secrets.minecraft-environment = {
    sopsFile = ./secrets.yaml;
    owner = config.services.minecraft-servers.user;
    group = config.services.minecraft-servers.group;
    restartUnits = [ "minecraft-server-vanilla.service" ];
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.11";
}
