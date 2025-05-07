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
  _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    inherit (config.nixpkgs) config;
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
    hostPlatform = system;
    config.allowUnfree = true;
    #overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
  };

  networking.hostName = hostname;

  environment = {
    shells = [
      pkgs.bash
      pkgs.nushell
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };
    direnv.enable = true;
  };

  fonts.packages = with pkgs-unstable; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
  ];
}
