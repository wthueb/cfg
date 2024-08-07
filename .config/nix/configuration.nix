{ pkgs, inputs, ... }:
{
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      substituters = ["https://cache.nixos.org"];
    };
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    #overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
    overlays = [];
  };

  environment.systemPackages = with pkgs; [
    inputs.nil.packages.aarch64-darwin.nil
    bashInteractive
    bat
    btop
    carapace
    coreutils
    curl
    dbeaver-bin
    delta
    dig
    discord
    fish
    fd
    ffmpeg-full
    fzf
    gcc
    gh
    git
    gnugrep
    gnumake
    gnused
    gnutar
    go
    google-cloud-sdk
    hyperfine
    inetutils
    jc
    jq
    less
    litecli
    neofetch
    neovim
    nixfmt-rfc-style
    nodejs_20
    nushell
    pyenv
    qbittorrent
    raycast
    rclone
    ripgrep
    rsync
    rustup
    sqlite
    spotify
    starship
    tldr
    tmux
    tree
    wezterm
    yt-dlp
    zoxide
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # remove all formulae not listed below
    };

    taps = [
      "homebrew/services"
      "mongodb/homebrew-brew"
    ];

    brews = [
      {
        name = "mongodb-community";
        start_service = true;
        restart_service = "changed";
      }
      # python build deps
      "mas"
      "openssl"
      "readline"
      "sqlite3"
      "xz"
      "zlib"
      "tcl-tk"
    ];

    masApps = {
      "Xcode" = 497799835;
    };

    casks = [
      # TODO: go through apps and add them here
      "bartender"
      "bitwarden"
      "docker"
      #"firefox"
      #"google-chrome"
      "hammerspoon"
      "karabiner-elements"
      "plex"
    ];
  };

  environment = {
    shells = [
      pkgs.bash
      pkgs.fish
      pkgs.nushell
    ];
    loginShell = pkgs.nushell;
    variables = {
      XDG_CONFIG_HOME = "/Users/wil/.config";
    };
  };

  programs = {
    nix-index.enable = true;
  };

  services = {
    nix-daemon.enable = true;
    karabiner-elements.enable = true;
    sketchybar.enable = true;
    skhd.enable = true;
    yabai = {
      enable = true;
      enableScriptingAddition = true;
    };
  };

  launchd.user.agents.raycast = {
    serviceConfig.ProgramArguments = [ "/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast" ];
    serviceConfig.RunAtLoad = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "SourceCodePro"
        "FiraCode"
      ];
    })
  ];

  system = {
    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };
    };

    stateVersion = 4;
  };

  security = {
    accessibilityPrograms = [
      "${pkgs.yabai}/bin/yabai"
      "${pkgs.skhd}/bin/skhd"
    ];

    pam.enableSudoTouchIdAuth = true;

    sudo.extraConfig = ''
      wil ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
