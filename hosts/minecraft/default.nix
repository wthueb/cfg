{
  config,
  pkgs,
  inputs,
  ...
}:
let
  jmxAgent = pkgs.prometheus-jmx-javaagent;
  jmxConfig = (pkgs.formats.yaml { }).generate "minecraft-jmx.yml" {
    startDelaySeconds = 30;
    lowercaseOutputName = true;
    includeObjectNames = [ "net.minecraft.server:type=Server" ];
    rules = [
      {
        pattern = "net.minecraft.server<type=Server><>averageTickTime";
        name = "minecraft_server_average_tick_time_seconds";
        help = "Average Minecraft server tick duration in seconds.";
        type = "GAUGE";
        valueFactor = 0.001;
      }
    ];
  };
in
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
        enable-jmx-monitoring = true;
        enable-rcon = true;
        "rcon.password" = "@rcon_password@";
      };

      jvmOpts = "-Xms6G -Xmx6G -XX:+UseZGC -XX:+ZGenerational -javaagent:${jmxAgent}/lib/jmx_prometheus_javaagent-${jmxAgent.version}.jar=0.0.0.0:9225:${jmxConfig}";
    };
  };

  wthueb.exporters.scrapeTargets = [
    {
      job = "minecraft";
      port = 9225;
    }
  ];

  sops.secrets.minecraft-environment = {
    owner = config.services.minecraft-servers.user;
    group = config.services.minecraft-servers.group;
    restartUnits = [ "minecraft-server-vanilla.service" ];
  };

  system.stateVersion = "24.11";
}
