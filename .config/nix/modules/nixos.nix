{
  pkgs,
  ...
}:
{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      extraCommands = ''
        iptables -A nixos-fw -p all -s 192.168.1.0/24 -j nixos-fw-accept
      '';
      extraStopCommands = ''
        iptables -D nixos-fw -p all -s 192.168.1.0/24 -j nixos-fw-accept || true
      '';
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
    git
    neovim
    wget
  ];

  programs.nix-ld.enable = true;

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

  systemd.settings.Manager.RunTimeWatchdogSec = "30s";

  users.users."wil" = {
    name = "wil";
    uid = 1000;
    home = "/home/wil";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
    ];
    shell = pkgs.nushell;
  };

  services.getty.autologinUser = "wil";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
