{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    btop
    carapace
    delta
    dig
    dua
    fd
    fzf
    gh
    gnugrep
    gnumake
    gnused
    gnutar
    jc
    jq
    less
    nixfmt-rfc-style
    nodejs
    nushell
    python3
    ripgrep
    rsync
    rustup
    starship
    tldr
    tmux
    tree
    unzip
    uv
  ];

  programs.direnv.enable = true;
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
