{
  pkgs,
  lib,
  hostname,
  ...
}:
{
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    }
    // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      dates = "weekly";
      persistent = true;
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
    };
  };

  networking.hostName = hostname;

  environment = {
    shells = [
      pkgs.bashInteractive
      pkgs.nushell
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      bashInteractive
      coreutils
      curl
      fd
      file
      git
      gnugrep
      gnused
      gnutar
      neovim
      nil
      nushell
      rsync
      wget
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
  ];
}
