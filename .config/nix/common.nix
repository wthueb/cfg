{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:
{
  _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (config.nixpkgs) config system;
  };

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
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      let
        fromUnstable = pkg: final: prev: {
          ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${final.system}.${pkg};
        };
      in
      [
        (fromUnstable "carapace")
        (fromUnstable "neovim")
        (fromUnstable "nushell")
        (fromUnstable "opencode")
        (fromUnstable "starship")
      ];
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

  programs.nix-index = {
    enable = true;
  }
  // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  programs.direnv.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
  ];
}
