{ pkgs, pkgs-unstable, ... }:

{
  home.username = "wil";
  home.homeDirectory = "/home/wil";

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  home.packages = [
    pkgs.carapace
    pkgs.dua
    pkgs.nil
    pkgs.nixfmt-rfc-style
    pkgs.nushell
    pkgs.starship
    pkgs.uv
  ];

  programs.neovim.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "24.11";
}
