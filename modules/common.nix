{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
{
  networking.hostName = hostname;

  home-manager.users.wil.wthueb = lib.getAttrs (builtins.filter (
    n: builtins.hasAttr n config.wthueb
  ) (import ../lib/features.nix).names) config.wthueb;

  environment = {
    systemPackages = with pkgs; [
      bashInteractive
      curl
      diffutils
      fd
      file
      findutils
      git
      gnugrep
      gnused
      gnutar
      htop
      inetutils
      neovim
      nushell
      procps
      rsync
      unzip
      uutils-coreutils-noprefix
      wget
      zip
    ];
    shells = [
      pkgs.bashInteractive
      pkgs.nushell
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  services.tailscale.enable = true;

  users.users.wil.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
  ];
}
