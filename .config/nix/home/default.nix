{
  pkgs,
  ...
}:
{
  imports = [
    ./nu.nix
  ];

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
    bash.enable = true;
    bat.enable = true;
    btop.enable = true;
    carapace = {
      enable = true;
    };
    direnv = {
      enable = true;
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
    ripgrep.enable = true;
    starship = {
      enable = true;
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

  home.shell.enableShellIntegration = true;

  services = {
    skhd.enable = pkgs.stdenv.isDarwin;
    ssh-agent.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.enable = true;

  home.stateVersion = "24.11";
}
