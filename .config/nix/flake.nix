{
  description = "wthueb's macbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, ...}:
    let
    configuration = { pkgs, ... }: {
      nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";

      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];

      environment.systemPackages = with pkgs; [
        bat
        coreutils
        curl
        delta
        dig
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
        htop
        inetutils
        jq
        less
        neofetch
        neovim-nightly
        nodejs_20
        nushell
        pyenv
        qbittorrent
        raycast
        rclone
        ripgrep
        rsync
        sqlite
        tldr
        tmux
        tree
        wezterm
        yt-dlp
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
          "openssl"
          "readline"
          "sqlite3"
          "xz"
          "zlib"
          "tcl-tk"
        ];

        casks = [
          "bartender"
          "docker"
          "hammerspoon"
        ];
      };

      environment.shells = [ pkgs.fish pkgs.nushell pkgs.zsh ];
      environment.loginShell = pkgs.nushell;
      environment.variables = {
        XDG_CONFIG_HOME = "/Users/wil/.config";
      };

      programs = {
        nix-index.enable = true;
        zsh = {
          enable = true;
          promptInit = '''';
        };
      };

      services.karabiner-elements.enable = true;
      services.nix-daemon.enable = true;
      services.sketchybar.enable = true;
      services.skhd.enable = true;
      services.yabai.enable = true;

      launchd.user.agents.raycast = {
        serviceConfig.ProgramArguments = [ "/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast" ];
        serviceConfig.RunAtLoad = true;
      };

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "SourceCodePro" "FiraCode" ]; })
      ];

      system.defaults = {
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

      security.accessibilityPrograms = [
        "${pkgs.yabai}/bin/yabai"
        "${pkgs.skhd}/bin/skhd"
      ];
      security.pam.enableSudoTouchIdAuth = true;
      security.sudo.extraConfig = ''
        wil ALL=(ALL) NOPASSWD: ALL
      '';

      system.stateVersion = 4;

      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
    };
  in
  {
    darwinConfigurations."wil-mac" = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        configuration
# inputs.home-manager.darwinModules.home-manager
# {
#   home-manager = {
#     useGlobalPkgs = true;
#     useUserPackages = true;
#     users.wil.imports = [ ./modules/home-manager ];
#   };
# }
      ];
    };

    darwinPackages = self.darwinConfigurations."wil-mac".pkgs;
  };
}
