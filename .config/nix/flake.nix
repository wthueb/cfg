{
  description = "macbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    mongodb-homebrew-brew = {
      url = "github:mongodb/homebrew-brew";
      flake = false;
    };

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
        fd
        ffmpeg
        fzf
        gcc
        gh
        git
        gnugrep
        gnumake
        gnused
        gnutar
        go
        htop
        inetutils
        jq
        less
        neofetch
        neovim-nightly
        nodejs_20
        pyenv # TODO: remove this and use nix-shell
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
      ];

      environment.shells = [ pkgs.zsh ];
      environment.loginShell = pkgs.zsh;

      programs.nix-index.enable = true;
      programs.zsh.enable = true;

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
        dock.autohide = true;
        dock.mru-spaces = false;

        finder.AppleShowAllExtensions = true;
      };

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
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "wil";
            enableRosetta = true;
            taps = {
              "homebrew/core" = inputs.homebrew-core;
              "homebrew/cask" = inputs.homebrew-cask;
              "mongodb/homebrew-brew" = inputs.mongodb-homebrew-brew;
            };
            mutableTaps = false;
          };
        }
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
