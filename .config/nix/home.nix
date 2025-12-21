{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 15d";
  };

  home.packages = with pkgs; [
    delta
    dig
    dua
    gh
    gnugrep
    gnumake
    gnused
    gnutar
    jc
    nixfmt-rfc-style
    nodejs
    nushell
    opencode
    openssh
    python3
    rsync
    rustup
    tmux
    tree
    unzip
  ];

  programs = {
    bat.enable = true;
    btop.enable = true;
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    jq.enable = true;
    less.enable = true;
    neovim.enable = true;
    ripgrep.enable = true;
    starship = {
      enable = true;
      enableNushellIntegration = true;
    };
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
    uv.enable = true;
    wezterm.enable = true;
  };

  services = {
    skhd.enable = pkgs.stdenv.isDarwin;
  };

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
