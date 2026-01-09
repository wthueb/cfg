{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
    dates = "weekly";
    persistent = true;
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
    bash = {
      enable = true;
    }
    # nushell isn't supported directly as a login shell on macos, so we just use bash
    # and launch nushell from it instead (only as a login shell so we can still use bash normally)
    # see nix-darwin/nix-darwin#1028
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      profileExtra = ''
        exec nu
      '';
    };
    bat.enable = true;
    btop.enable = true;
    carapace = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
    discord = {
      enable = true;
      settings = {
        SKIP_HOST_UPDATE = true;
        DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
      };
    };
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    jq.enable = true;
    less.enable = true;
    neovim.enable = true;
    nushell = {
      enable = true;
      configDir = "${config.xdg.configHome}/nushell/nix";
      plugins = with pkgs.nushellPlugins; [
        desktop_notifications
        formats
        polars
        query
      ];
    };
    ripgrep.enable = true;
    starship = {
      enable = true;
      enableBashIntegration = true;
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
    VISUAL = "nvim";
  };

  xdg.enable = true;

  home.stateVersion = "24.11";
}
