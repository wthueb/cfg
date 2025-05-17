{
  self,
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  system,
  hostname,
  ...
}:
{
  fileSystems."/mnt/data" = {
    device = "192.168.1.207:/volume2/data";
    fsType = "nfs";
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "ter-i20b";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    ffmpeg-full
    gcc
    git
    vim
    wget
  ];

  programs.neovim = {
    enable = true;
    # won't need overrideAttrs after next stable
    package = pkgs-unstable.neovim-unwrapped.overrideAttrs (old: {
      meta = old.meta or { } // {
        maintainers = [ ];
      };
    });
  };

  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
    # only allow PasswordAuthentication on local network/tailscale
    extraConfig = ''
      PasswordAuthentication no

      Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10
        PasswordAuthentication yes
    '';
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.cron.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  systemd.watchdog.runtimeTime = "30s";

  users.groups.plex.gid = 5000;

  users.users."wil" = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "plex"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
    ];
    shell = pkgs-unstable.nushell;
    packages = with pkgs-unstable; [
      carapace
      dig
      gnugrep
      gnumake
      gnused
      gnutar
      jc
      jq
      nodejs
      python3
      rsync
      starship
      tldr
      tree
      unzip
    ];
  };

  services.getty.autologinUser = "wil";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system.stateVersion = "24.11";
}
